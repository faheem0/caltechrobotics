#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>

#include "graph.h"

static void dft_traverse(pixel_node_t * curr_node, BOOL traverse_mark)
{
	if(curr_node == NULL) return;
	if(curr_node->traversed == traverse_mark) return;
	curr_node->traversed = traverse_mark;
	dft_traverse(curr_node->up, traverse_mark);
	dft_traverse(curr_node->right, traverse_mark);
	dft_traverse(curr_node->down, traverse_mark);
	dft_traverse(curr_node->left, traverse_mark);
}

static char get_Y_YUYV(char *image, int pixel_index)
{
	return image[pixel_index*2];
}

pixel_clstr_lst_t* apply_highpass_Y_YUYV
	(char *image, int width, int height, char threshold)
{
	int length, i, row, col;
	char Y_value;
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
		if (clstr->p_clstr->traversed){
			prev_clstr->next = clstr->next;
			free(clstr->p_clstr->pixel);
			free(clstr->p_clstr);
			free(clstr);
			clstr = prev_clstr->next;
		} else {
			dft_traverse(clstr->p_clstr, TRUE);
			prev_clstr = clstr;
			clstr = clstr->next;
		}
	}
	clstr = clstr_lst->next;
	free(clstr_lst);
	clstr_lst = clstr;
	for(; clstr != NULL; clstr = clstr->next) 
		dft_traverse(clstr->p_clstr, FALSE);
	return clstr_lst;
}
