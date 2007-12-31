#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>

#include "graph.h"

extern unsigned char *clip_buffer;

typedef enum Stack_Operation_e {
	PUSH,
	POP,
	TOP,
	CLEAR
} Stack_Operation_t;
/*Optimize Later*/
static pixel_node_t *dfs_stack(Stack_Operation_t op, pixel_node_t *pnode)
{
	static pixel_node_t **pnode_stack = NULL;
	static int pos = -1;
	static int stack_size = 0;
	static int stack_base_size = 512;

	if (pnode_stack == NULL){
		stack_size = stack_base_size;
		pnode_stack = (pixel_node_t **)malloc(stack_size*sizeof(pixel_node_t *));
	}

	switch(op){
		case PUSH:
			pos++;
			if (pos == stack_size){
				stack_size *= 2;
				pnode_stack = (pixel_node_t **)realloc(pnode_stack,
						stack_size*sizeof(pixel_node_t *));
			}
			pnode_stack[pos] = pnode;
			return NULL;
			break;
		case POP:
			if (pos < 0) return NULL;
			pos--;
			return pnode_stack[pos+1];
			break;
		case TOP:
			if (pos < 0) return NULL;
			return pnode_stack[pos];
			break;
		case CLEAR:
			pos = -1;
			if (pnode_stack != NULL)
				free(pnode_stack);
			pnode_stack = NULL;
			return NULL;
			break;
		default:
			return NULL;
	}
}



static void dfs_traverse(pixel_node_t * pnode, BOOL traverse_mark, 
		void (*func)(pixel_node_t *, unsigned char *), unsigned char *image)
{
	pixel_node_t *curr_node;

	dfs_stack(PUSH,pnode);

	while((curr_node = dfs_stack(TOP,NULL)) != NULL){
		if (curr_node->traversed == traverse_mark){
			dfs_stack(POP,NULL);
			if(func != NULL) (*func)(curr_node, image);
			continue;
		}
		curr_node->traversed = traverse_mark;
		if(curr_node->up != NULL
			&& curr_node->up->traversed != traverse_mark){
			dfs_stack(PUSH,curr_node->up);
			continue;
		}
		else if(curr_node->right != NULL
			&& curr_node->right->traversed != traverse_mark){
			dfs_stack(PUSH,curr_node->right);
			continue;
		}
		else if(curr_node->down != NULL
			&& curr_node->down->traversed != traverse_mark){
			dfs_stack(PUSH,curr_node->down);
			continue;
		}
		else if(curr_node->left != NULL
			&& curr_node->left->traversed != traverse_mark){
			dfs_stack(PUSH,curr_node->left);
			continue;
		}
	}
}	


static void dfs_traverse1(pixel_node_t * curr_node, BOOL traverse_mark, 
		void (*func)(pixel_node_t *, unsigned char *), unsigned char *image)
{
	if(curr_node == NULL) return;
	if(curr_node->traversed == traverse_mark) return;
	curr_node->traversed = traverse_mark;
	dfs_traverse(curr_node->up, traverse_mark, func, image);
	dfs_traverse(curr_node->right, traverse_mark, func, image);
	dfs_traverse(curr_node->down, traverse_mark, func, image);
	dfs_traverse(curr_node->left, traverse_mark, func, image);
	if(func != NULL) (*func)(curr_node, image);
}

static unsigned char get_Y_YUYV(unsigned char *image, int pixel_index)
{
	return image[pixel_index*2];
}

pixel_clstr_lst_t* apply_highpass_Y_YUYV
	(unsigned char *image, int width, int height, unsigned char threshold)
{
	int length, i, row, col;
	unsigned char Y_value;
	pixel_clstr_lst_t *clstr_lst, *clstr, *prev_clstr;
	pixel_clstr_lst_t *prev_row_lst;
	pixel_clstr_lst_t *curr_row_lst, *curr_row_node, *prev_row_node;
	pixel_node_t *p_node;

	length = width * height;
	clstr_lst = (pixel_clstr_lst_t *) calloc(1, sizeof(pixel_clstr_lst_t));
	clstr = clstr_lst;

	prev_row_lst = NULL; prev_row_node = NULL;

	i = 0;
	for (row = 0; row < height; row++) {
		curr_row_lst = (pixel_clstr_lst_t *) calloc(1, sizeof(pixel_clstr_lst_t));
		curr_row_node = curr_row_lst;
		prev_row_node = curr_row_node;
		for(col = 0; col < width; col++) {
			Y_value = get_Y_YUYV(image, i);
			i++;
			if (Y_value < threshold) continue;

			curr_row_node->next = (pixel_clstr_lst_t *) 
				calloc(1, sizeof(pixel_clstr_lst_t));
			prev_row_node = curr_row_node;
			curr_row_node = curr_row_node->next;
			curr_row_node->p_clstr = (pixel_node_t *)
				calloc(1, sizeof(pixel_node_t));
			p_node = curr_row_node->p_clstr;
			p_node->pixel = (pixel_t *) 
				calloc(1, sizeof(pixel_t));

			p_node->pixel->row = row;
			p_node->pixel->col = col;
			p_node->pixel->Y = Y_value;

			if(prev_row_node == curr_row_lst) continue;
			if(prev_row_node->p_clstr->pixel->col != col - 1) continue;

			prev_row_node->p_clstr->right = p_node;
			p_node->left = prev_row_node->p_clstr;

		}
		curr_row_node = curr_row_lst;
		curr_row_lst = curr_row_lst->next;
		free(curr_row_node);

		if (curr_row_lst == NULL){
			prev_row_lst = NULL;
			continue;
		}
		
		for(curr_row_node = curr_row_lst; 
				curr_row_node != NULL; 
				curr_row_node = curr_row_node->next){
			if (prev_row_lst == NULL) break;
			p_node = curr_row_node->p_clstr;
			while (prev_row_lst != NULL){
				if (prev_row_lst->p_clstr->pixel->col < 
						p_node->pixel->col){
					prev_row_lst = prev_row_lst->next;
				} else {
					if (prev_row_lst->p_clstr->pixel->col ==
						p_node->pixel->col){
						/*link these two nodes:*/
						//Crashes when both links are connected: Error
						prev_row_lst->p_clstr->down = p_node;
						p_node->up = prev_row_lst->p_clstr;
						prev_row_lst = prev_row_lst->next;
					}
					break;
				}
			}
		}
		
		prev_row_lst = curr_row_lst;
		clstr->next = curr_row_lst;
		for(clstr = curr_row_lst; clstr->next != NULL; clstr = clstr->next);
	}

	prev_clstr = clstr_lst;
	clstr = clstr_lst->next;
	while(clstr != NULL){
		if (clstr->p_clstr->traversed == TRUE){
			prev_clstr->next = clstr->next;
			free(clstr);
			clstr = prev_clstr->next;

		} else {
			dfs_traverse(clstr->p_clstr, TRUE, NULL, NULL);
			prev_clstr = clstr;
			clstr = clstr->next;
		}
	}
	clstr = clstr_lst->next;
	free(clstr_lst);
	clstr_lst = clstr;

	for(; clstr != NULL; clstr = clstr->next) 
		dfs_traverse(clstr->p_clstr, FALSE, NULL, NULL);
	return clstr_lst;
}

void extract_pixel(pixel_node_t *node, unsigned char *image)
{
	int i,j,n;
	unsigned char Y;
	int *a;
	static int width = 0;
	if (node == NULL) {
		width = *((int *) image);
		return;
	}

	i = node->pixel->row;
	j = node->pixel->col;
	Y = node->pixel->Y;

	n = i*width + j;
	a = (int *) image;
	a[n] = (int)Y;
}

void delete_clstr(pixel_node_t *node, unsigned char *crap)
{
	
	if(node->up != NULL) node->up->down = NULL;
	if(node->down != NULL) node->down->up = NULL;
	if(node->left != NULL) node->left->right =  NULL;
	if(node->right != NULL) node->right->left =  NULL;
	free(node->pixel);
	free(node);
}

void get_clstrs(int *image, int width, int height, int threshold)
{	
	int i, j, n;
	pixel_clstr_lst_t *clstr_lst, *clstr;

	clstr_lst = apply_highpass_Y_YUYV(clip_buffer, width, height, (unsigned char) threshold);
	
	n = 0;
	for(i = 0; i < width; i++){
		for(j = 0; j < height; j++){
			image[n] = 0;
			n++;
		}
	}

	extract_pixel(NULL, (unsigned char *)(&width));
	for(clstr = clstr_lst; clstr != NULL; clstr = clstr->next){
		dfs_traverse(clstr->p_clstr, TRUE, extract_pixel, (unsigned char *)image); 
	}
	for(clstr = clstr_lst; clstr != NULL;){
		dfs_traverse(clstr->p_clstr, FALSE, delete_clstr, NULL);
		clstr_lst = clstr->next;
		free(clstr);
		clstr = clstr_lst;
	}

}
