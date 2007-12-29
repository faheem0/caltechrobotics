/* 
 * File:   capture.h
 * Author: tonyfwu
 *
 * Created on December 28, 2007, 10:53 AM
 */

#ifndef _CAPTURE_H
#define	_CAPTURE_H

#ifdef	__cplusplus
extern "C" {
#endif

void capture_frame(int *);
void start_camera(char *, int, int);
void stop_camera(void);
void test_image(char *, int *, int, int);

#ifdef	__cplusplus
}
#endif

#endif	/* _CAPTURE_H */

