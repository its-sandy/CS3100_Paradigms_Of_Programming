(defun isElement (a li)
	; finds if element 'a' is present in list li
	(cond
		((null li) nil)
		((= a (first li)) t)
		(t (isElement a (rest li)))
		)
	)

(defun makeSet (li)
	; removes repeated elements from list 'li' and then sorts the resulting elements
	(setq ans (list))
	(dolist (a li)
		(if (not (isElement a ans))
			(setq ans (cons a ans)) ; adds the element only when it is not already present
			)
		)
	(return-from makeSet (sort ans '<))
	)

(defun binIntersect (li1 li2)
	; finds intersection of 2 sets
	(setq ans (list))
	(dolist (a li1)
		(if (isElement a li2) ; loops over all elements of 'li1' and checks if it is present in 'li2'
			(setq ans (cons a ans))
			)
		)
	(return-from binIntersect (makeSet ans))
	)

(defun genIntersect (lili)
	; finds intersection of a sequence of sets
	(if (null lili)
		(return-from genIntersect (list))
		)

	(setq ans (makeset (first lili))) ; initalize resultant as the first set
	(dolist (li lili)
		(setq ans (binIntersect ans li))
		)
	(return-from genIntersect (makeSet ans))
	)

(defun binUnion (li1 li2)
	; finds union of 2 sets
	(setq ans (list))
	(dolist (a li1)
		(setq ans (cons a ans))
		)
	(dolist (a li2)
		(setq ans (cons a ans))
		)
	(return-from binUnion (makeSet ans)) ; we remove multiple occurences of the same element
	)

(defun genUnion (lili)
	; finds union of a sequence of sets
	(setq ans (list))
	(dolist (li lili)
		(setq ans (binUnion ans li))
		)
	(return-from genUnion (makeSet ans))
	)

(defun binSubtract (li1 li2)
	; finds li1 - li2
	(setq ans (list))
	(dolist (a li1)
		(if (not (isElement a li2)) ; checks for elements in li1 that are not in li2
			(setq ans (cons a ans))
			)
		)
	(return-from binSubtract (makeSet ans))
	)

(defun genSubtract (lili)
	; from the first set of lili, subtracts the remaining sets
	(setq ans (makeset (first lili))) ; initially we start with all distinct elements of li1
	(setq lili (rest lili))
	(dolist (li lili)
		(setq ans (binSubtract ans li)) ; we keep removing common elements 
		)
	(return-from genSubtract (makeSet ans))
	)

(defun cartesian (lili)
	; finds cartesian product of the sequence of sets
	(dolist (li lili)
		(if (null li)
			(return-from cartesian (list)) ; cartesian product is a null set if even one of the sets is null 
			)
		)

	(setq lili (reverse lili))	; we reverse the order of sets so that appending the elements can be done at the front itself 
	(setq ans (list (list)))	; answer is initialized as a set containing only the null set
	(dolist (li lili)
		(setq temp ans)
		(setq ans (list))
		(dolist (a li)
			(dolist (term temp)
				(setq ans (cons (cons a term) ans)) ; find all combinations of existing terms appended with elements of next list
				)
			)
		)
	(setq ans (sort (copy-seq ans) 'listComparator))
	(return-from cartesian ans)
	)

(defun powerSet (li)
	; finds powerset of the given set
	(setq li (makeset li))
	(setq ans (list (list))) ; answer is initialized as a set containing only the null set
	(dolist (a li)
		(setq temp ans)
		(dolist (term temp) ; for every element in the set, it can either be present or not present in the existing subsets
			(setq ans (cons (cons a term) ans))
			)
		)
	(return-from powerSet (sortLili ans)) ; each subset is sorted and also, the powerset contatining them is sorted 
	)

(defun listComparator (li1 li2)
	; a user-defined comparator to compare 2 list objects
	(cond 
		((< (list-length li1) (list-length li2))	(return-from listComparator t)) ; list sizes are first compared
		((> (list-length li1) (list-length li2))	(return-from listComparator nil))
		)
	(setq n (list-length li1))
	(dotimes (ind n) ; if sizes are same, the point of first difference is considered
		(cond
			((< (nth ind li1) (nth ind li2))	(return-from listComparator t))
			((> (nth ind li1) (nth ind li2))	(return-from listComparator nil))
			)
		)
	(return-from listComparator t)
	)

(defun sortLili (lili)
	; function to sort each list in a list of list object, and then sort the list of list as a whole
	(setq newlili (list))
	(dolist (li lili)
		(setq newlili (cons (sort (copy-seq li) '<) newlili))
		)
	(sort newlili 'listComparator)
	(return-from sortLili newlili)
	)

(defun printLi (li)
	; function to print a list object as per given format
	(write-line "(")
	(dolist (a li)
		(write a)
		(terpri)
		)
	(write-line ")")
	)

(defun printLili (lili)
	; function to print a list of list object as per given format
	(write-line "(")
	(dolist (li lili)
		(printLi li)
		)
	(write-line ")")
	)

(defun getParamSet (lili indices)
	; Input : list of list "lili", list "indices"
	; Output: list of list containing the lists at locations of "indices" in "lili"
	(setq paramSets (list))
	(dolist (ind indices)
		(setq paramSets (cons (nth ind lili) paramSets))
		)
	(setq paramSets (reverse paramSets))
	(return-from getParamSet paramSets)
	)

(defun zeroIndex (li)
	; Input : one-indexed list of indices
	; Output: corresponding zero-indexed list of indices
	(setq tli li)
	(dotimes (n (list-length tli))
		(setf (nth n tli) (- (nth n tli) 1))
		)
	(return-from zeroIndex tli)
	)

(setq num (read))		; number of input sets
(setq inpsets (list))	; list of input sets

(dotimes (ind num)
	(setq curset (read))
	(setq inpsets (cons curset inpsets))	; appending at front orders the sets in reverse order
	)

(setq inpsets (reverse inpsets))	; to undo the effect of appending in front

(setq numQueries (read))	; number of queries
(dotimes (ind numQueries)
	(setq qtype (read))	; query type
	(cond
		(
			(= qtype 1)
			(setq indices (zeroIndex (read-from-string (concatenate 'string "(" (read-line) ")")))) ; gets the required zero indexed indices
			(printLi (genUnion (getParamSet inpsets indices)))
			)
		(
			(= qtype 2)
			(setq indices (zeroIndex (read-from-string (concatenate 'string "(" (read-line) ")"))))
			(printLi (genIntersect (getParamSet inpsets indices)))
			)
		(
			(= qtype 3)
			(setq indices (zeroIndex (read-from-string (concatenate 'string "(" (read-line) ")"))))
			(printLi (genSubtract (getParamSet inpsets indices)))
			)
		(
			(= qtype 4)
			(setq indices (zeroIndex (read-from-string (concatenate 'string "(" (read-line) ")"))))
			(printLili (cartesian (getParamSet inpsets indices)))
			)
		(
			(= qtype 5)
			(setq index (read))
			(setq index (- index 1)) ; zero indexing
			(setq elem (read))
			(if (isElement elem (nth index inpsets))
				(write-line "1")
				(write-line "0")
				)
			)
		(
			(= qtype 6)
			(setq index (read))
			(setq index (- index 1))
			(printLili (powerSet (nth index inpsets)))
			)
		)
	)