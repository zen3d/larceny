/* Copyright 1998 Lars T Hansen.
 *
 * $Id$
 *
 * Larceny run-time system -- old heap data structure.
 *
 * An `old_heap_t' represents an "old" heap -- an older generation in a
 * generational garbage collector.  Although objects can be allocated
 * directly in an old heap, most objects are promoted into old heaps from
 * younger heaps.
 */

#ifndef INCLUDED_OLD_HEAP_T_H
#define INCLUDED_OLD_HEAP_T_H

#include "larceny-types.h"

struct old_heap {
  gc_t *collector;
    /* The garbage collector that controls this heap.
       */

  char *id;
    /* A human-comprehensible string identifying the heap and its strategy;
       used by the startup banner.
       */

  word code;
    /* A numeric code identifying the heap, used by the heap dumper/loader.
       */

  int maximum;
     /* The maximum storage that can be allocated in this generation.
	This field is valid following a call to before_collection()
	and synchronize().
	*/

  int allocated;
     /* The amount of storage currently allocated in this generation.
	This field is valid following a call to before_collection()
	and synchronize().
	*/

  bool has_popular_objects;
  int bytes_live_last_major_gc;
  int words_from_nursery_last_major_gc;
  bool was_target_during_gc;

  bool reallocate_whole_semispace;

  region_group_t group;
  old_heap_t *prev_in_group;
  old_heap_t *next_in_group;

  struct {
    int summarizer;
    int marker;
  } incoming_words;

  void *data;
     /* Data private to the heap implementation.
	*/

  int  (*initialize)( old_heap_t *heap );
    /* A method that finishes initialization, after all heaps have
       been allocated.
       */
  
  void (*collect)( old_heap_t *heap, gc_type_t request );
     /* A method that requests a garbage collection in the heap.
	Request is the type of GC requested.
	*/

  void (*collect_into)( old_heap_t *heap, gc_type_t request, old_heap_t *to );
     /* A method that requests a garbage collection in the heap.
	Request is the type of GC requested.
	To is initial target region (aka tospace).
	*/

  void (*before_collection)( old_heap_t *heap );
     /* A method that is called before any garbage collection.
	*/

  void (*after_collection)( old_heap_t *heap );
     /* A method that is called after any garbage collection.
	*/

  void (*stats)( old_heap_t *heap );
     /* Update the stats for the heap in the central repository.

	Old invariant, does not hold any more, do not rely on it:
	When called at the beginning of a collection, the before_collection()
	method will not yet have been called, and when called at the end of
	a collection, the after_collection() method will have been called
	first.
	*/

  word *(*data_load_area)( old_heap_t *heap, int nbytes );
     /* A method that allocates a block of at least `nbytes'
	consecutive bytes, suitable for loading data into.  A pointer
	to the first word of the block is returned.  No garbage 
	collection will be triggered.

	nbytes > 0
	*/

  int  (*load_prepare)( old_heap_t *heap, metadata_block_t *m, 
		        heapio_t *h, word **lo, word **hi );
     /* UNDOCUMENTED: Used by the future heap dumper.
        */

  int  (*load_data)( old_heap_t *heap, metadata_block_t *m, heapio_t *h );
     /* UNDOCUMENTED: Used by the future heap dumper.
        */

  void (*set_policy)( old_heap_t *heap, int op, int value );
     /* A method that gives external agents control over GC policy.
        */

  void (*set_gen_no)( old_heap_t *heap, int gen_no );
    /* Changes gen_no associated with heap (and the gen_no of the
       semispace associated with heap).
       */

  semispace_t* (*current_space)( old_heap_t *heap );
    /* Returns internal semispace structure that holds data for heap.
       (Felix is doing evil abstraction breaking stuff; but is it
       really evil if the abstraction was ill-chosen in the first
       place?)
       */

  void  (*assimilate)( old_heap_t *heap, semispace_t *ss );
    /* requires: ss->gen_no matches heap->gen_no.
       Merges all chunks in ss into heap; invalidates ss.
       */

  void* (*enumerate)( old_heap_t *heap, 
		      void *visitor( word *addr, int tag, void *accum ),
		      void *accum_init );
    /* Invokes visitor on each object allocated in heap; note
       that this might include objects unreachable from the roots, 
       but all visited objects (and the object graph induced by treating
       the visited objects as additional roots) should be properly
       formatted.
       */

  bool (*is_address_mapped)( old_heap_t *heap, word *addr, bool noisy );
    /* Returns true iff 'addr' is an object in 'heap'. 
       */

  void (*synchronize)( old_heap_t *heap );
    /* Synchronizes internal state of heap, so that the maximim and allocated
       fields are valid.
     */

  region_group_t (*get_group)( old_heap_t *heap );
    /* Produces group for heap. */
  void (*switch_group)( old_heap_t *heap, region_group_t new_grp );
    /* Reassigns heap to new_grp, removing it from its old group. */
  old_heap_t *(*get_next_in_group)( old_heap_t *heap );
    /* Iterates through group; produces NULL when none are left.
     * See also group_to_heap above. */
};

/* The initialize and set_policy arguments may be NULL. */

old_heap_t *create_old_heap_t(
  char *id,
  word code,
  int  (*initialize)( old_heap_t *heap ), 
  void (*collect)( old_heap_t *heap, gc_type_t request ),
  void (*collect_into)( old_heap_t *heap, gc_type_t request, old_heap_t *to ),
  void (*before_collection)( old_heap_t *heap ),
  void (*after_collection)( old_heap_t *heap ),
  void (*stats)( old_heap_t *heap ),
  word *(*data_load_area)( old_heap_t *heap, int nbytes ),
  int  (*load_prepare)( old_heap_t *heap, metadata_block_t *m, 
		        heapio_t *h, word **lo, word **hi ),
  int  (*load_data)( old_heap_t *heap, metadata_block_t *m, heapio_t *h ),
  void (*set_policy)( old_heap_t *heap, int op, int value ),
  void (*set_gen_no)( old_heap_t *heap, int gen_no ),
  semispace_t *(*current_space)( old_heap_t *heap ),
  void (*assimilate)( old_heap_t *heap, semispace_t *ss ),
  void *(*enumerate)( old_heap_t *heap, 
		      void *visitor( word *addr, int tag, void *accum ),
		      void *accum_init ),
  bool (*is_address_mapped)( old_heap_t *heap, word *addr, bool noisy ),
  void (*synchronize)( old_heap_t *heap ), 
  void *data
);

#define oh_initialize( oh )        ((oh)->initialize( oh ))
#define oh_collect( oh,r )         ((oh)->collect( oh,r ))
#define oh_collect_into( oh,r,to ) ((oh)->collect_into( oh,r,to ))
#define oh_before_collection( oh ) ((oh)->before_collection( oh ))
#define oh_after_collection( oh )  ((oh)->after_collection( oh ))
#define oh_stats( oh )             ((oh)->stats( oh ))
#define oh_data_load_area( oh, n ) ((oh)->data_load_area( oh, n ))
#define oh_set_policy( oh, x, y )  ((oh)->set_policy( oh, x, y ))
#define oh_set_gen_no( oh, gno )   ((oh)->set_gen_no( oh, gno ))
#define oh_assimilate( oh, ss )    ((oh)->assimilate( oh, ss ))
#define oh_current_space( oh )     ((oh)->current_space( oh ))
#define oh_is_address_mapped( oh,a,n)((oh)->is_address_mapped( (oh), (a), (n) ))
#define oh_synchronize( oh )       ((oh)->synchronize( oh ))

#endif  /* INCLUDED_OLD_HEAP_T_H */

/* eof */
