/* 
 * File:   graph.h
 * Author: tonyfwu
 *
 * Created on December 27, 2007, 10:42 AM
 */

#ifndef _GRAPH_H
#define	_GRAPH_H

#ifdef	__cplusplus
extern "C" {
#endif

#define FALSE 0
#define TRUE 1

	typedef char BOOL;
	typedef struct pixel {
		unsigned char Y;
		unsigned char Cr;
		unsigned char Cb;
		int row;
		int col;
	} pixel_t;
	
	typedef struct pixel_node {
		pixel_t * pixel;
		struct pixel_node * left;
		struct pixel_node * up;
		struct pixel_node * down;
		struct pixel_node * right;
		char traversed;
	} pixel_node_t;

	typedef struct pixel_clstr_lst {
		pixel_node_t * p_clstr;
		struct pixel_clstr_lst * next;
	} pixel_clstr_lst_t;

	void get_clstrs(int *, int , int , int );
#ifdef	__cplusplus
}
#endif

#endif	/* _GRAPH_H */
