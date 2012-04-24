/*
 * Pixel-manipulation routines .. first, if building with SIMD
 * optimizations, grab the mmx intrinsics header.
 */
#ifdef WITH_SIMD
#include <mmintrin.h>
#endif



/* rendering routines that use SIMD instructions need to reset the cpu afterward */
#ifdef WITH_SIMD
#define SIMD_ADJ _mm_empty()
#else
#define SIMD_ADJ
#endif



/* and check to make sure we've got a byte order set here */
#if !(defined R_ADJ && defined G_ADJ && defined B_ADJ && defined A_ADJ)
#error Pixel order not set
#endif





/*
 * Endian-neutral pixel operations
 */
#define rgb_pixel(src, tgt) \
	do \
		{ \
			*(int32_t *)(tgt) = *(int32_t *)(src); \
		} \
	while(0)


#define xor_pixel(src, flt) \
	do \
		{ \
			*(int32_t *)(src) ^= *(int32_t *)(flt); \
		} \
	while(0)


#define lut_pixel(src, l, flt) \
	do \
		{ \
			if( *(flt) ) \
				{ \
					*((src)+B_ADJ) = ((lut *)l)->b[*((src)+B_ADJ)]; \
					*((src)+G_ADJ) = ((lut *)l)->g[*((src)+G_ADJ)]; \
					*((src)+R_ADJ) = ((lut *)l)->r[*((src)+R_ADJ)]; \
				} \
		} \
	while(0)



/*
 * SIMD-optimized pixel operations
 */
#ifdef WITH_SIMD

#define rgba_pixel(src, tgt) \
	do \
		{ \
			int a; \
			/* an mmx register for the source, the filter, and results on both sides of the conditional */ \
			__m64 sx, tx, a0x, a1x; \
			\
			/* load the alpha components */ \
			a = *((src)+A_ADJ); \
			a0x = _mm_set1_pi16(a); \
			a1x = _mm_sub_pi16(_mm_set1_pi16(RGB_MAX), a0x); \
			\
			/* load the source and targets */ \
			sx = _mm_cvtsi32_si64(*(int32_t *)(src)); \
			tx = _mm_cvtsi32_si64(*(int32_t *)(tgt)); \
			sx = _mm_unpacklo_pi8(sx, _mm_setzero_si64()); \
			tx = _mm_unpacklo_pi8(tx, _mm_setzero_si64()); \
			\
			/* do the multiplications */ \
			sx = _mm_mullo_pi16(sx, a0x); \
			tx = _mm_mullo_pi16(tx, a1x); \
			\
			/* add the blended pixels */ \
			a0x = _mm_add_pi16(sx, tx); \
			\
			/* \
			 * and the tricky part - this is jim blinn's method to divide by 255: \
			 * intermediate i = a * b + 128 \
			 * result = (i + (i>>8)) >> 8 \
			 */ \
			a0x = _mm_add_pi16(a0x, _mm_set1_pi16(128)); \
			a1x = a0x; \
			a1x = _mm_srli_pi16(a1x, A_DIV); \
			a0x = _mm_add_pi16(a0x, a1x); \
			a0x = _mm_srli_pi16(a0x, A_DIV); \
			\
			/* and save the result */ \
			tx = _mm_packs_pu16(a0x, _mm_setzero_si64()); \
			*(int32_t *)(tgt) = _mm_cvtsi64_si32(tx); \
			*((tgt)+A_ADJ) = a; \
		} \
	while(0)


#define hl_pixel(src, flt) \
	do \
		{ \
			/* an mmx register for the source, the filter, and results on both sides of the conditional */ \
			__m64 sx, fx, ax, bx, rx_lt, rx_gt; \
			\
			sx = _mm_cvtsi32_si64(*(int32_t *)(src)); \
			fx = _mm_cvtsi32_si64(*(int32_t *)(flt)); \
			\
			/* unpack the source and filter from 8 bits to 16 */ \
			sx = _mm_unpacklo_pi8(sx, _mm_setzero_si64()); \
			fx = _mm_unpacklo_pi8(fx, _mm_setzero_si64()); \
			\
			/* multiply for the less-than result */ \
			rx_lt = _mm_mullo_pi16(sx, fx); \
			rx_lt = _mm_srli_pi16(rx_lt, LT_DIV); \
			\
			/* prepare the accumulator for the greater-than result */ \
			ax = _mm_sub_pi16(_mm_set1_pi16(LT_MAX), sx); \
			bx = _mm_sub_pi16(fx, _mm_set1_pi16(LT_MID)); \
			rx_gt = _mm_mullo_pi16(ax, bx); \
			rx_gt = _mm_srai_pi16(rx_gt, LT_DIV); \
			rx_gt = _mm_add_pi16(sx, rx_gt); \
			\
			/* now we've got both halves of the branch ready .. */ \
			ax = _mm_cmpgt_pi16(_mm_set1_pi16(LT_MID+1), fx); \
			rx_lt = _mm_and_si64(ax, rx_lt); \
			rx_gt = _mm_andnot_si64(ax, rx_gt); \
			sx = _mm_or_si64(_mm_setzero_si64(), rx_lt); \
			sx = _mm_or_si64(sx, rx_gt); \
			\
			/* pack and store the result pixel */ \
			sx = _mm_packs_pu16(sx, _mm_setzero_si64()); \
			*(int32_t *)(src) = _mm_cvtsi64_si32(sx); \
		} \
	while(0)


#define sl_pixel(src, flt) \
	do \
		{ \
			/* an mmx register for the source, the filter, and results on both sides of the conditional */ \
			__m64 sx, fx, ax, bx, rx_lt, rx_gt; \
			\
			sx = _mm_cvtsi32_si64(*(int32_t *)(src)); \
			fx = _mm_cvtsi32_si64(*(int32_t *)(flt)); \
			\
			/* unpack the source and filter from 8 bits to 16 */ \
			sx = _mm_unpacklo_pi8(sx, _mm_setzero_si64()); \
			fx = _mm_unpacklo_pi8(fx, _mm_setzero_si64()); \
			\
			/* prepare the accumulator for the less-than result */ \
			ax = _mm_sub_pi16(_mm_set1_pi16(LT_MAX), sx); \
			bx = _mm_sub_pi16(fx, _mm_set1_pi16(LT_MID)); \
			rx_lt = _mm_mullo_pi16(ax, bx); \
			rx_lt = _mm_srai_pi16(rx_lt, LT_DIV); \
			rx_lt = _mm_add_pi16(rx_lt, sx); \
			\
			/* multiply for the greater-than result */ \
			rx_gt = _mm_mullo_pi16(sx, fx); \
			rx_gt = _mm_srli_pi16(rx_gt, LT_DIV); \
			\
			/* now we've got both halves of the branch ready .. */ \
			ax = _mm_cmpgt_pi16(_mm_set1_pi16(LT_MID+1), fx); \
			rx_lt = _mm_and_si64(ax, rx_lt); \
			rx_gt = _mm_andnot_si64(ax, rx_gt); \
			sx = _mm_or_si64(_mm_setzero_si64(), rx_lt); \
			sx = _mm_or_si64(sx, rx_gt); \
			\
			/* pack and store the result pixel */ \
			sx = _mm_packs_pu16(sx, _mm_setzero_si64()); \
			*(int32_t *)(src) = _mm_cvtsi64_si32(sx); \
		} \
	while(0)


#define br_pixel(src, flt) \
	do \
		{ \
			/* an mmx register for the source and for the filter */ \
			__m64 sx, fx; \
			\
			sx = _mm_cvtsi32_si64(*(int32_t *)(src)); \
			fx = _mm_cvtsi32_si64(*(int32_t *)(flt)); \
			\
			/* unpack the source and filter from 8 bits to 16 */ \
			sx = _mm_unpacklo_pi8(sx, _mm_setzero_si64()); \
			fx = _mm_unpacklo_pi8(fx, _mm_setzero_si64()); \
			\
			/* \
			 * multiply--ignoring the high word because the byte-values will never \
			 * exceed the low word--and shift by the brightness multiplier \
			 */ \
			sx = _mm_mullo_pi16(sx, fx); \
			sx = _mm_srli_pi16(sx, BR_DIV); \
			\
			/* pack and store the result pixel */ \
			sx = _mm_packs_pu16(sx, _mm_setzero_si64()); \
			*(int32_t *)(src) = _mm_cvtsi64_si32(sx); \
		} \
	while(0)


#define ct_pixel(src, flt) \
	do \
		{ \
			/* an mmx register for the source and for the filter */ \
			__m64 sx, a0x, a1x; \
			\
			/* unpack the source pixel */ \
			sx = _mm_cvtsi32_si64(*(int32_t *)(src)); \
			sx = _mm_unpacklo_pi8(sx, _mm_setzero_si64()); \
			\
			/* a0x now holds the contrast-adjust used in the result .. (CT_ADJ - *(flt)) */ \
			a0x = _mm_set1_pi16(CT_ADJ); \
			a0x = _mm_sub_pi16(a0x, _mm_set1_pi16(*(flt))); \
			\
			/* and a1x has the source pixel used in the result .. (*(flt) * *(src) >> CT_DIV) */ \
			a1x = _mm_mullo_pi16(sx, _mm_set1_pi16(*(flt))); \
			a1x = _mm_srli_pi16(a1x, CT_DIV); \
			\
			/* add a0x and a1x and pack the result */ \
			a0x = _mm_add_pi16(a0x, a1x); \
			a0x = _mm_packs_pu16(a0x, _mm_setzero_si64()); \
			*(int32_t *)(src) = _mm_cvtsi64_si32(a0x); \
		} \
	while(0)


#define sat_pixel(src, flt) \
	do \
		{ \
			int lum; \
			\
			/* an mmx register for the source, filter, and results */ \
			__m64 sx, a0x, a1x; \
			\
			/* generate the luminance pixel */ \
			lum = (*((src)+B_ADJ) * B_WGT + *((src)+G_ADJ) * G_WGT + *((src)+R_ADJ) * R_WGT) >> WGT_DIV; \
			\
			/* unpack the source, filter, and luminance values */ \
			sx = _mm_cvtsi32_si64(*(int32_t *)(src)); \
			sx = _mm_unpacklo_pi8(sx, _mm_setzero_si64()); \
			\
			/* a0x now holds the proportion of luminance used in the result .. (SAT_ADJ0 - *(flt)) * lum */ \
			a0x = _mm_set1_pi16(SAT_ADJ0); \
			a0x = _mm_sub_pi16(a0x, _mm_set1_pi16(*(flt))); \
			a0x = _mm_mullo_pi16(a0x, _mm_set1_pi16(lum)); \
			\
			/* and a1x has the proportion of source pixel used in the result .. (*(flt) - SAT_ADJ1) * (src) */ \
			a1x = _mm_set1_pi16(SAT_ADJ1); \
			a1x = _mm_sub_pi16(_mm_set1_pi16(*(flt)), a1x); \
			a1x = _mm_mullo_pi16(sx, a1x); \
			\
			/* add a0x and a1x, and divide by the saturation multiplier */ \
			a0x = _mm_add_pi16(a0x, a1x); \
			a0x = _mm_srai_pi16(a0x, SAT_DIV); \
			\
			/* pack and store the result pixel */ \
			a0x = _mm_packs_pu16(a0x, _mm_setzero_si64()); \
			*(int32_t *)(src) = _mm_cvtsi64_si32(a0x); \
		} \
	while(0)


#else


#define rgba_pixel(src, tgt) \
	do \
		{ \
			int a; \
			a = *(src+A_ADJ); \
			*(tgt+B_ADJ) = (a * *(src+B_ADJ) + (RGB_MAX - a) * *(tgt+B_ADJ)) / 255; \
			*(tgt+G_ADJ) = (a * *(src+G_ADJ) + (RGB_MAX - a) * *(tgt+G_ADJ)) / 255; \
			*(tgt+R_ADJ) = (a * *(src+R_ADJ) + (RGB_MAX - a) * *(tgt+R_ADJ)) / 255; \
			*(tgt+A_ADJ) = a; \
		} \
	while(0)

#define hl_pixel(src, flt) \
	do \
		{ \
			*((src)+B_ADJ) = (*((flt)+B_ADJ) <= LT_MID) ? (*((src)+B_ADJ) * *((flt)+B_ADJ)) >> LT_DIV : *((src)+B_ADJ) + ((LT_MAX - *((src)+B_ADJ)) * (*((flt)+B_ADJ) - LT_MID) >> LT_DIV); \
			*((src)+G_ADJ) = (*((flt)+G_ADJ) <= LT_MID) ? (*((src)+G_ADJ) * *((flt)+G_ADJ)) >> LT_DIV : *((src)+G_ADJ) + ((LT_MAX - *((src)+G_ADJ)) * (*((flt)+G_ADJ) - LT_MID) >> LT_DIV); \
			*((src)+R_ADJ) = (*((flt)+R_ADJ) <= LT_MID) ? (*((src)+R_ADJ) * *((flt)+R_ADJ)) >> LT_DIV : *((src)+R_ADJ) + ((LT_MAX - *((src)+R_ADJ)) * (*((flt)+R_ADJ) - LT_MID) >> LT_DIV); \
		} \
	while(0)

#define sl_pixel(src, flt) \
	do \
		{ \
			int res; \
			res = (*((flt)+B_ADJ) <= LT_MID) ? *((src)+B_ADJ) + ((LT_MAX - *((src)+B_ADJ)) * (*((flt)+B_ADJ) - LT_MID) >> LT_DIV) : (*((src)+B_ADJ) * *((flt)+B_ADJ)) >> LT_DIV; *((src)+B_ADJ) = res < 0 ? 0 : (res > RGB_MAX) ? RGB_MAX : res; \
			res = (*((flt)+G_ADJ) <= LT_MID) ? *((src)+G_ADJ) + ((LT_MAX - *((src)+G_ADJ)) * (*((flt)+G_ADJ) - LT_MID) >> LT_DIV) : (*((src)+G_ADJ) * *((flt)+G_ADJ)) >> LT_DIV; *((src)+G_ADJ) = res < 0 ? 0 : (res > RGB_MAX) ? RGB_MAX : res; \
			res = (*((flt)+R_ADJ) <= LT_MID) ? *((src)+R_ADJ) + ((LT_MAX - *((src)+R_ADJ)) * (*((flt)+R_ADJ) - LT_MID) >> LT_DIV) : (*((src)+R_ADJ) * *((flt)+R_ADJ)) >> LT_DIV; *((src)+R_ADJ) = res < 0 ? 0 : (res > RGB_MAX) ? RGB_MAX : res; \
		} \
	while(0)

#define br_pixel(src, flt) \
	do \
		{ \
			int res; \
			res = *((flt)+B_ADJ) * *((src)+B_ADJ) >> BR_DIV; *((src)+B_ADJ) = res > RGB_MAX ? RGB_MAX : res; \
			res = *((flt)+G_ADJ) * *((src)+G_ADJ) >> BR_DIV; *((src)+G_ADJ) = res > RGB_MAX ? RGB_MAX : res; \
			res = *((flt)+R_ADJ) * *((src)+R_ADJ) >> BR_DIV; *((src)+R_ADJ) = res > RGB_MAX ? RGB_MAX : res; \
		} \
	while(0)

#define ct_pixel(src, flt) \
	do \
		{ \
			int res; \
			res = (CT_ADJ - *(flt)) + (*(flt) * *((src)+B_ADJ) >> CT_DIV); *((src)+B_ADJ) = res < 0 ? 0 : (res > RGB_MAX) ? RGB_MAX : res; \
			res = (CT_ADJ - *(flt)) + (*(flt) * *((src)+G_ADJ) >> CT_DIV); *((src)+G_ADJ) = res < 0 ? 0 : (res > RGB_MAX) ? RGB_MAX : res; \
			res = (CT_ADJ - *(flt)) + (*(flt) * *((src)+R_ADJ) >> CT_DIV); *((src)+R_ADJ) = res < 0 ? 0 : (res > RGB_MAX) ? RGB_MAX : res; \
		} \
	while(0)

#define sat_pixel(src, flt) \
	do \
		{ \
			int lum, res; \
			lum = (*((src)+B_ADJ) * B_WGT + *((src)+G_ADJ) * G_WGT + *((src)+R_ADJ) * R_WGT) >> WGT_DIV; \
			res = ((SAT_ADJ0 - *(flt)) * lum + (*(flt) - SAT_ADJ1) * *((src)+B_ADJ)) >> SAT_DIV; *((src)+B_ADJ) = res < 0 ? 0 : (res > RGB_MAX) ? RGB_MAX : res; \
			res = ((SAT_ADJ0 - *(flt)) * lum + (*(flt) - SAT_ADJ1) * *((src)+G_ADJ)) >> SAT_DIV; *((src)+G_ADJ) = res < 0 ? 0 : (res > RGB_MAX) ? RGB_MAX : res; \
			res = ((SAT_ADJ0 - *(flt)) * lum + (*(flt) - SAT_ADJ1) * *((src)+R_ADJ)) >> SAT_DIV; *((src)+R_ADJ) = res < 0 ? 0 : (res > RGB_MAX) ? RGB_MAX : res; \
		} \
	while(0)


#endif
