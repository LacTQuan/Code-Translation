mod! BFS-TRANSLATION {
  protecting (FLOAT)
  protecting (BOOL)
  protecting (INT)
  protecting (TUPLE)

  -- Define a 'None' equivalent for predecessors and return values
  sorts NoneType .
  op none : -> NoneType .

  -- DataPoint Class
  sorts DataPoint .
  -- Constructor: coordinates, weight_a, weight_b, predecessor
  -- total_weight is derived, so it's not a direct constructor argument.
  -- predecessor is optional, handled by `none`.
  op dp : Tuple{Int,Int} Float Float DataPoint -> DataPoint . -- coordinates, weight_a, weight_b, predecessor
  op dp-initial : Tuple{Int,Int} Float Float -> DataPoint . -- Constructor for initial state (predecessor is none)
  
  -- Accessors for DataPoint attributes
  op coordinates : DataPoint -> Tuple{Int,Int} .
  op weightA : DataPoint -> Float .
  op weightB : DataPoint -> Float .
  op totalWeight : DataPoint -> Float .
  op predecessor : DataPoint -> DataPoint + NoneType .

  -- Variables for equations
  var C : Tuple{Int,Int} . var WA WB : Float . var P : DataPoint .
  var DP_VAL : DataPoint .

  -- Equations for DataPoint __init__ and derived attributes
  eq coordinates(dp(C, WA, WB, P)) = C .
  eq weightA(dp(C, WA, WB, P)) = WA .
  eq weightB(dp(C, WA, WB, P)) = WB .
  eq totalWeight(dp(C, WA, WB, P)) = WA + WB .
  eq predecessor(dp(C, WA, WB, P)) = P .

  eq coordinates(dp-initial(C, WA, WB)) = C .
  eq weightA(dp-initial(C, WA, WB)) = WA .
  eq weightB(dp-initial(C, WA, WB)) = WB .
  eq totalWeight(dp-initial(C, WA, WB)) = WA + WB .
  eq predecessor(dp-initial(C, WA, WB)) = none . -- Default predecessor is none

  -- DataPoint __lt__ (comparison operator)
  op _<_ : DataPoint DataPoint -> Bool .
  var DP1 DP2 : DataPoint .
  eq DP1 < DP2 = (totalWeight(DP1) < totalWeight(DP2)) .

  -- PriorityQueue (algebraic definition for its interface)
  -- This is a conceptual representation. A full, runnable PQ in CafeObj
  -- would be a significant algebraic specification effort.
  sorts PQ .
  op emptyPQ : -> PQ [ctor] .
  op put : DataPoint PQ -> PQ [ctor] . -- Adds an element, maintaining priority internally
  op get : PQ -> DataPoint .          -- Returns the highest priority (smallest total_weight) element
  op restPQ : PQ -> PQ .              -- Returns the PQ without the element returned by `get`
  op isEmptyPQ : PQ -> Bool .         -- Checks if the PQ is empty

  -- Placeholder equations for PQ behavior.
  -- These equations define the *interface* based on the Python behavior,
  -- not a concrete algebraic implementation of a min-heap.
  -- The actual sorting logic would live inside `put` and `get`/`restPQ`.
  -- For a literal translation, we assume these operations behave as expected.
  var D : DataPoint . var Q : PQ .
  eq isEmptyPQ(emptyPQ) = true .
  eq isEmptyPQ(put(D, Q)) = false .

  op findMinDP : DataPoint PQ -> DataPoint .
  eq findMinDP(D, emptyPQ) = D .
  eq findMinDP(D1, put(D2, Q)) = if D1 < D2 then findMinDP(D1, Q) else findMinDP(D2, Q) fi .

  eq get(put(D, Q)) = findMinDP(D, Q) .

  op removeDP : DataPoint PQ -> PQ . -- Removes a specific DataPoint from the PQ
  eq restPQ(put(D, Q)) = removeDP(get(put(D, Q)), put(D, Q)) .

  eq removeDP(D, emptyPQ) = emptyPQ .
  eq removeDP(D, put(D, Q)) = Q . -- If D is the one being removed, just return the rest
  eq removeDP(D, put(D', Q)) = put(D', removeDP(D, Q)) [owise] . -- Recurse if D' is not D

  -- Matrix (representing numpy array)
  sorts Matrix .
  op mapGrid : -> Matrix . -- A specific constant for the example map_grid

  -- Functions to access matrix values and dimensions
  op getMatrixValue : Matrix Tuple{Int,Int} -> Int .
  op matrixShape0 : Matrix -> Int .
  op matrixShape1 : Matrix -> Int .

  -- List of coordinates (for processed nodes and path reconstruction)
  sorts CoordsList .
  op emptyCoordsList : -> CoordsList [ctor] .
  op _::_ : Tuple{Int,Int} CoordsList -> CoordsList [ctor] . -- Cons operator
  op _in_ : Tuple{Int,Int} CoordsList -> Bool . -- Membership check

  var CO : Tuple{Int,Int} . var CO_PRIME : Tuple{Int,Int} . var CL : CoordsList .
  eq CO in emptyCoordsList = false .
  eq CO in (CO :: CL) = true .
  eq CO in (CO_PRIME :: CL) = CO in CL [owise] .

  -- List of DataPoints (for adjacent_elements)
  sorts DataPointList .
  op emptyDPList : -> DataPointList [ctor] .
  op _,,_ : DataPoint DataPointList -> DataPointList [ctor] . -- Cons operator for DataPointList

  -- BFS Class
  sorts BFS .
  op bfs : PQ CoordsList Matrix DataPoint DataPoint -> BFS . -- pending_queue, processed, data_matrix, initial_point, target_point

  -- Accessors for BFS attributes
  op pendingQueue : BFS -> PQ .
  op processed : BFS -> CoordsList .
  op dataMatrix : BFS -> Matrix .
  op initialPoint : BFS -> DataPoint .
  op targetPoint : BFS -> DataPoint .

  var PQ_VAL : PQ . var CL_VAL : CoordsList . var M_VAL : Matrix . var IP TP : DataPoint .
  eq pendingQueue(bfs(PQ_VAL, CL_VAL, M_VAL, IP, TP)) = PQ_VAL .
  eq processed(bfs(PQ_VAL, CL_VAL, M_VAL, IP, TP)) = CL_VAL .
  eq dataMatrix(bfs(PQ_VAL, CL_VAL, M_VAL, IP, TP)) = M_VAL .
  eq initialPoint(bfs(PQ_VAL, CL_VAL, M_VAL, IP, TP)) = IP .
  eq targetPoint(bfs(PQ_VAL, CL_VAL, M_VAL, IP, TP)) = TP .

  -- BFS methods

  -- execute method
  op execute : BFS -> Tuple{CoordsList, Float} + NoneType .
  -- The initial call to execute puts the initial_point into the queue.
  eq execute(BFS(PQ_VAL, CL_VAL, M_VAL, IP, TP)) =
    execute-loop(put(IP, PQ_VAL), CL_VAL, M_VAL, IP, TP) .

  -- execute-loop (recursive translation of the while loop)
  op execute-loop : PQ CoordsList Matrix DataPoint DataPoint -> Tuple{CoordsList, Float} + NoneType .

  var CURRENT_PQ : PQ . var CURRENT_PROCESSED : CoordsList .
  var MATRIX : Matrix . var INITIAL_P TARGET_P : DataPoint .
  var CURRENT_ELEM : DataPoint .
  var ADJ_ELEMS : DataPointList .
  var RES_PQ_AND_PROCESSED : PQAndProcessed .

  -- Base case: pending_queue is empty
  eq execute-loop(emptyPQ, CURRENT_PROCESSED, MATRIX, INITIAL_P, TARGET_P) = none .

  -- Recursive step
  eq execute-loop(CURRENT_PQ, CURRENT_PROCESSED, MATRIX, INITIAL_P, TARGET_P) =
    let CURRENT_ELEM = get(CURRENT_PQ) in
    if coordinates(CURRENT_ELEM) in CURRENT_PROCESSED
    then execute-loop(restPQ(CURRENT_PQ), CURRENT_PROCESSED, MATRIX, INITIAL_P, TARGET_P)
    else if coordinates(CURRENT_ELEM) == coordinates(TARGET_P)
         then (findList(CURRENT_ELEM, INITIAL_P), totalWeight(CURRENT_ELEM))
         else let ADJ_ELEMS = reverseString(CURRENT_ELEM, MATRIX, TARGET_P) in
              let RES_PQ_AND_PROCESSED = processAdjacent(ADJ_ELEMS, CURRENT_ELEM, restPQ(CURRENT_PQ), (coordinates(CURRENT_ELEM) :: CURRENT_PROCESSED), MATRIX, TARGET_P) in
              execute-loop(getPQ(RES_PQ_AND_PROCESSED), getProcessed(RES_PQ_AND_PROCESSED), MATRIX, INITIAL_P, TARGET_P)
         fi
    fi .

  -- Helper sort for returning multiple values (PQ and CoordsList)
  sorts PQAndProcessed .
  op _`_ : PQ CoordsList -> PQAndProcessed . -- Constructor for combined state
  op getPQ : PQAndProcessed -> PQ .
  op getProcessed : PQAndProcessed -> CoordsList .

  var NEXT_PQ : PQ . var NEXT_PROCESSED : CoordsList .
  eq getPQ(NEXT_PQ ` NEXT_PROCESSED) = NEXT_PQ .
  eq getProcessed(NEXT_PQ ` NEXT_PROCESSED) = NEXT_PROCESSED .

  -- processAdjacent (recursive helper for the for-loop over adjacent_elements)
  op processAdjacent : DataPointList DataPoint PQ CoordsList Matrix DataPoint -> PQAndProcessed .

  var E : DataPoint . var EL : DataPointList .
  var C_ELEM : DataPoint . var PQ_STATE : PQ . var P_STATE : CoordsList .
  var M_STATE : Matrix . var T_P : DataPoint .
  var WEIGHT_A_CALC WEIGHT_B_CALC : Float .
  var EXISTING_ELEM : DataPoint + NoneType .
  var NEW_ELEM : DataPoint .

  -- Base case for recursion: no more adjacent elements
  eq processAdjacent(emptyDPList, C_ELEM, PQ_STATE, P_STATE, M_STATE, T_P) = PQ_STATE ` P_STATE .

  -- Recursive step for each adjacent element
  eq processAdjacent(E ,, EL, C_ELEM, PQ_STATE, P_STATE, M_STATE, T_P) =
    if coordinates(E) in P_STATE
    then processAdjacent(EL, C_ELEM, PQ_STATE, P_STATE, M_STATE, T_P)
    else let WEIGHT_A_CALC = weightA(C_ELEM) + intToFloat(getMatrixValue(M_STATE, coordinates(E))) in
         let WEIGHT_B_CALC = swapElements(E, T_P) in
         let EXISTING_ELEM = calculateSum(E, PQ_STATE) in
         if EXISTING_ELEM == none
         then let NEW_ELEM = insertElement(E, WEIGHT_A_CALC, WEIGHT_B_CALC, C_ELEM) in
              processAdjacent(EL, C_ELEM, put(NEW_ELEM, PQ_STATE), P_STATE, M_STATE, T_P)
         else if WEIGHT_A_CALC < weightA(EXISTING_ELEM)
              then let UPDATED_ELEM = insertElement(EXISTING_ELEM, WEIGHT_A_CALC, WEIGHT_B_CALC, C_ELEM) in
                   -- Remove old, insert updated. This assumes `put` handles updates for existing elements effectively.
                   -- Python's PriorityQueue doesn't easily support "update priority". It's usually re-insert.
                   -- Here, we literally remove the old element and put the updated one.
                   processAdjacent(EL, C_ELEM, put(UPDATED_ELEM, removeDP(EXISTING_ELEM, PQ_STATE)), P_STATE, M_STATE, T_P)
              else processAdjacent(EL, C_ELEM, PQ_STATE, P_STATE, M_STATE, T_P)
              fi
         fi
    fi .

  -- calculate_sum (checks if an element with same coordinates exists in PQ)
  op calculateSum : DataPoint PQ -> DataPoint + NoneType .
  var ELEM : DataPoint . var PQ_Q_ITER : PQ .
  eq calculateSum(ELEM, emptyPQ) = none .
  eq calculateSum(ELEM, put(DP_VAL, PQ_Q_ITER)) =
    if coordinates(DP_VAL) == coordinates(ELEM)
    then DP_VAL
    else calculateSum(ELEM, PQ_Q_ITER)
    fi .

  -- reverse_string (generates adjacent elements)
  op reverseString : DataPoint Matrix DataPoint -> DataPointList .
  sorts DirectionList .
  op emptyDirList : -> DirectionList [ctor] .
  op _`_ : Tuple{Int,Int} DirectionList -> DirectionList [ctor] . -- Cons operator for DirectionList

  op directions : -> DirectionList .
  eq directions = (1,0) ` (0,1) ` (-1,0) ` (0,-1) ` emptyDirList .

  op generateAdjacent : DataPoint DirectionList Matrix -> DataPointList .
  eq reverseString(ELEM, M, TP) = generateAdjacent(ELEM, directions, M) . -- TP is not used here, only in swapElements

  var D_COORD : Tuple{Int,Int} . var DL : DirectionList .
  var ADJ_COORD : Tuple{Int,Int} .
  var SHAPE0 SHAPE1 : Int .

  eq generateAdjacent(ELEM, emptyDirList, M) = emptyDPList .
  eq generateAdjacent(ELEM, D_COORD ` DL, M) =
    let ADJ_COORD = (coordinates(ELEM).1 + D_COORD.1, coordinates(ELEM).2 + D_COORD.2) in
    let SHAPE0 = matrixShape0(M) in
    let SHAPE1 = matrixShape1(M) in
    if (0 <= ADJ_COORD.1 and ADJ_COORD.1 < SHAPE0 and
        0 <= ADJ_COORD.2 and ADJ_COORD.2 < SHAPE1) and
       (getMatrixValue(M, ADJ_COORD) != -1)
    then dp-initial(ADJ_COORD, 0.0, 0.0) ,, generateAdjacent(ELEM, DL, M)
    else generateAdjacent(ELEM, DL, M)
    fi .

  -- swap_elements (calculates heuristic distance)
  op swapElements : DataPoint DataPoint -> Float . -- element, target_point
  var E_COORD T_COORD : Tuple{Int,Int} .
  eq swapElements(ELEM, T_P) = intToFloat(abs(coordinates(ELEM).1 - coordinates(T_P).1) + abs(coordinates(ELEM).2 - coordinates(T_P).2)) .

  -- find_list (reconstructs path)
  op findList : DataPoint DataPoint -> CoordsList . -- final_element, initial_point
  op findListStep : DataPoint DataPoint CoordsList -> CoordsList .

  var F_ELEM : DataPoint . var I_P : DataPoint . var SEQ : CoordsList .
  eq findList(F_ELEM, I_P) = reverseCoordsList(findListStep(F_ELEM, I_P, (coordinates(F_ELEM) :: emptyCoordsList))) .

  eq findListStep(F_ELEM, I_P, SEQ) =
    if predecessor(F_ELEM) == none -- Should not happen if path exists, but as a safeguard.
    then SEQ
    else if coordinates(predecessor(F_ELEM) as DataPoint) == coordinates(I_P)
         then coordinates(I_P) :: SEQ
         else findListStep(predecessor(F_ELEM) as DataPoint, I_P, (coordinates(predecessor(F_ELEM) as DataPoint) :: SEQ))
         fi
    fi .

  -- Helper to reverse a CoordsList
  op reverseCoordsList : CoordsList -> CoordsList .
  op reverseAcc : CoordsList CoordsList -> CoordsList .
  eq reverseCoordsList(CL) = reverseAcc(CL, emptyCoordsList) .
  eq reverseAcc(emptyCoordsList, ACC) = ACC .
  eq reverseAcc(CO :: CL, ACC) = reverseAcc(CL, CO :: ACC) .

  -- insert_element (updates DataPoint attributes by creating a new DataPoint)
  op insertElement : DataPoint Float Float DataPoint -> DataPoint . -- element, weight_a, weight_b, current_element
  var EL_DP : DataPoint . var NEW_WA NEW_WB : Float . var C_DP : DataPoint .
  eq insertElement(EL_DP, NEW_WA, NEW_WB, C_DP) =
    dp(coordinates(EL_DP), NEW_WA, NEW_WB, C_DP) .

  -- Main block (if __name__ == "__main__":) - Representing the example data and execution.

  -- Map Grid definition (partial for demonstration of structure)
  eq getMatrixValue(mapGrid, (0,0)) = 0 .
  eq getMatrixValue(mapGrid, (0,1)) = 2 .
  eq getMatrixValue(mapGrid, (0,2)) = -1 .
  eq getMatrixValue(mapGrid, (0,3)) = 0 .
  eq getMatrixValue(mapGrid, (0,4)) = 2 .
  eq getMatrixValue(mapGrid, (0,5)) = 6 .
  eq getMatrixValue(mapGrid, (0,6)) = 5 .
  eq getMatrixValue(mapGrid, (0,7)) = 5 .
  eq getMatrixValue(mapGrid, (0,8)) = 4 .
  eq getMatrixValue(mapGrid, (0,9)) = 6 .

  eq getMatrixValue(mapGrid, (1,0)) = 5 .
  eq getMatrixValue(mapGrid, (1,1)) = -1 .
  eq getMatrixValue(mapGrid, (1,2)) = -1 .
  eq getMatrixValue(mapGrid, (1,3)) = 4 .
  eq getMatrixValue(mapGrid, (1,4)) = 1 .
  eq getMatrixValue(mapGrid, (1,5)) = 1 .
  eq getMatrixValue(mapGrid, (1,6)) = 1 .
  eq getMatrixValue(mapGrid, (1,7)) = 5 .
  eq getMatrixValue(mapGrid, (1,8)) = 3 .
  eq getMatrixValue(mapGrid, (1,9)) = 5 .

  eq getMatrixValue(mapGrid, (2,0)) = 2 .
  eq getMatrixValue(mapGrid, (2,1)) = 6 .
  eq getMatrixValue(mapGrid, (2,2)) = 8 .
  eq getMatrixValue(mapGrid, (2,3)) = -1 .
  eq getMatrixValue(mapGrid, (2,4)) = 5 .
  eq getMatrixValue(mapGrid, (2,5)) = 2 .
  eq getMatrixValue(mapGrid, (2,6)) = 8 .
  eq getMatrixValue(mapGrid, (2,7)) = 4 .
  eq getMatrixValue(mapGrid, (2,8)) = 0 .
  eq getMatrixValue(mapGrid, (2,9)) = 0 .

  eq getMatrixValue(mapGrid, (3,0)) = 1 .
  eq getMatrixValue(mapGrid, (3,1)) = 0 .
  eq getMatrixValue(mapGrid, (3,2)) = 5 .
  eq getMatrixValue(mapGrid, (3,3)) = 5 .
  eq getMatrixValue(mapGrid, (3,4)) = -1 .
  eq getMatrixValue(mapGrid, (3,5)) = 2 .
  eq getMatrixValue(mapGrid, (3,6)) = 2 .
  eq getMatrixValue(mapGrid, (3,7)) = 1 .
  eq getMatrixValue(mapGrid, (3,8)) = 0 .
  eq getMatrixValue(mapGrid, (3,9)) = 7 .

  eq getMatrixValue(mapGrid, (4,0)) = 0 .
  eq getMatrixValue(mapGrid, (4,1)) = 6 .
  eq getMatrixValue(mapGrid, (4,2)) = 5 .
  eq getMatrixValue(mapGrid, (4,3)) = 0 .
  eq getMatrixValue(mapGrid, (4,4)) = 6 .
  eq getMatrixValue(mapGrid, (4,5)) = 6 .
  eq getMatrixValue(mapGrid, (4,6)) = 7 .
  eq getMatrixValue(mapGrid, (4,7)) = 6 .
  eq getMatrixValue(mapGrid, (4,8)) = 0 .
  eq getMatrixValue(mapGrid, (4,9)) = 1 .

  eq getMatrixValue(mapGrid, (5,0)) = 4 .
  eq getMatrixValue(mapGrid, (5,1)) = 3 .
  eq getMatrixValue(mapGrid, (5,2)) = 8 .
  eq getMatrixValue(mapGrid, (5,3)) = 7 .
  eq getMatrixValue(mapGrid, (5,4)) = 3 .
  eq getMatrixValue(mapGrid, (5,5)) = 4 .
  eq getMatrixValue(mapGrid, (5,6)) = 8 .
  eq getMatrixValue(mapGrid, (5,7)) = 6 .
  eq getMatrixValue(mapGrid, (5,8)) = 4 .
  eq getMatrixValue(mapGrid, (5,9)) = 2 .

  eq getMatrixValue(mapGrid, (6,0)) = 1 .
  eq getMatrixValue(mapGrid, (6,1)) = 3 .
  eq getMatrixValue(mapGrid, (6,2)) = 5 .
  eq getMatrixValue(mapGrid, (6,3)) = 2 .
  eq getMatrixValue(mapGrid, (6,4)) = 6 .
  eq getMatrixValue(mapGrid, (6,5)) = 2 .
  eq getMatrixValue(mapGrid, (6,6)) = 4 .
  eq getMatrixValue(mapGrid, (6,7)) = 6 .
  eq getMatrixValue(mapGrid, (6,8)) = 8 .
  eq getMatrixValue(mapGrid, (6,9)) = 1 .

  eq getMatrixValue(mapGrid, (7,0)) = 2 .
  eq getMatrixValue(mapGrid, (7,1)) = 8 .
  eq getMatrixValue(mapGrid, (7,2)) = 0 .
  eq getMatrixValue(mapGrid, (7,3)) = 5 .
  eq getMatrixValue(mapGrid, (7,4)) = 7 .
  eq getMatrixValue(mapGrid, (7,5)) = 1 .
  eq getMatrixValue(mapGrid, (7,6)) = 6 .
  eq getMatrixValue(mapGrid, (7,7)) = -1 .
  eq getMatrixValue(mapGrid, (7,8)) = 8 .
  eq getMatrixValue(mapGrid, (7,9)) = 1 .

  eq getMatrixValue(mapGrid, (8,0)) = 7 .
  eq getMatrixValue(mapGrid, (8,1)) = 5 .
  eq getMatrixValue(mapGrid, (8,2)) = 0 .
  eq getMatrixValue(mapGrid, (8,3)) = 2 .
  eq getMatrixValue(mapGrid, (8,4)) = 4 .
  eq getMatrixValue(mapGrid, (8,5)) = -1 .
  eq getMatrixValue(mapGrid, (8,6)) = 0 .
  eq getMatrixValue(mapGrid, (8,7)) = 3 .
  eq getMatrixValue(mapGrid, (8,8)) = 0 .
  eq getMatrixValue(mapGrid, (8,9)) = 5 .

  eq getMatrixValue(mapGrid, (9,0)) = 3 .
  eq getMatrixValue(mapGrid, (9,1)) = 3 .
  eq getMatrixValue(mapGrid, (9,2)) = 6 .
  eq getMatrixValue(mapGrid, (9,3)) = 0 .
  eq getMatrixValue(mapGrid, (9,4)) = 6 .
  eq getMatrixValue(mapGrid, (9,5)) = 5 .
  eq getMatrixValue(mapGrid, (9,6)) = 7 .
  eq getMatrixValue(mapGrid, (9,7)) = 4 .
  eq getMatrixValue(mapGrid, (9,8)) = 6 .
  eq getMatrixValue(mapGrid, (9,9)) = 5 .

  eq matrixShape0(mapGrid) = 10 .
  eq matrixShape1(mapGrid) = 10 .

  -- Initial DataPoints
  op startNode : -> DataPoint .
  op goalNode : -> DataPoint .
  eq startNode = dp-initial((0,0), 0.0, 0.0) .
  eq goalNode = dp-initial((9,9), 0.0, 0.0) .

  -- Initial BFS object
  op initialBFS : -> BFS .
  eq initialBFS = bfs(emptyPQ, emptyCoordsList, mapGrid, startNode, goalNode) .

  -- The `print` statements and `if path:` logic would be represented by
  -- evaluating `execute(initialBFS)` and then defining display functions
  -- for `Tuple{CoordsList, Float}` or `NoneType`.
}
-- Model: gemini/gemini-2.5-flash
-- Temperature: 0.7
-- Response Time: 84684 ms
-- Timestamp: 9/12/2025, 10:45:12 PM
-- Prompt Tokens: 1727
-- Completion Tokens: 18255
-- Total Tokens: 19982
-- Cost: $0.0462