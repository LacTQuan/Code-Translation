-- Configuration
protecting (FLOAT)

-- Utility module for integer pairs (coordinates)
mod* NAT-PAIR {
  [NatPair]
  op <_,_> : Nat Nat -> NatPair
  op x : NatPair -> Nat
  op y : NatPair -> Nat
  op _+_ : NatPair NatPair -> NatPair
  eq < X, Y > + < X', Y' > = < X + X', Y' + Y > .
  op _==_ : NatPair NatPair -> Bool
  eq < X, Y > == < X', Y' > = (X == X') and (Y == Y') .
}

-- Utility module for a 2D matrix of integers
mod* MATRIX {
  pr(LIST{Int})
  pr(NAT-PAIR)
  [Matrix]
  op matrix : List{List{Int}} -> Matrix
  op shape0 : Matrix -> Nat
  op shape1 : Matrix -> Nat
  op _[_] : Matrix NatPair -> Int

  vars L L' : List{List{Int}} .
  var I J : Nat .
  eq shape0(matrix(L)) = length(L) .
  eq shape1(matrix(nil)) = 0 .
  eq shape1(matrix(L :: L')) = length(L) .
  eq matrix(L)[< I, J >] = nth(nth(L, I), J) .
}

-- Forward declaration for DataPoint
mod* DATA-POINT-FWD {
  [DataPoint]
}

-- List of DataPoints, to be used as a priority queue
mod* LIST-DATAPOINT {
  pr(LIST{DATA-POINT-FWD})
}

-- DataPoint class representation
mod* DATA-POINT {
  pr(DATA-POINT-FWD)
  pr(NAT-PAIR)
  pr(FLOAT)

  -- Sorts and Constructors
  op dataPoint : NatPair Float Float Float DataPoint -> DataPoint
  op null-dp : -> DataPoint

  -- Attributes
  op coordinates : DataPoint -> NatPair
  op weight-a : DataPoint -> Float
  op weight-b : DataPoint -> Float
  op total-weight : DataPoint -> Float
  op predecessor : DataPoint -> DataPoint

  -- Equations for attributes
  vars C : NatPair .
  vars WA WB TW : Float .
  var PRED : DataPoint .
  eq coordinates(dataPoint(C, WA, WB, TW, PRED)) = C .
  eq weight-a(dataPoint(C, WA, WB, TW, PRED)) = WA .
  eq weight-b(dataPoint(C, WA, WB, TW, PRED)) = WB .
  eq total-weight(dataPoint(C, WA, WB, TW, PRED)) = TW .
  eq predecessor(dataPoint(C, WA, WB, TW, PRED)) = PRED .

  -- __lt__ method
  op _<_ : DataPoint DataPoint -> Bool
  var DP1 DP2 : DataPoint .
  eq DP1 < DP2 = total-weight(DP1) < total-weight(DP2) .
}

-- Forward declaration for BFS
mod* BFS-FWD {
  [BFS]
}

-- Result type for the execute function
mod* PATH-RESULT {
  pr(LIST{NAT-PAIR})
  pr(FLOAT)
  [PathResult]
  op path-found : List{NatPair} Float -> PathResult
  op no-path : -> PathResult
}

-- Main BFS logic
mod* BFS-LOGIC {
  pr(BFS-FWD)
  pr(DATA-POINT)
  pr(MATRIX)
  pr(LIST-DATAPOINT)
  pr(LIST{NAT-PAIR})
  pr(PATH-RESULT)

  -- BFS sort and constructor
  op bfs : Matrix DataPoint DataPoint -> BFS
  
  -- Attribute accessors
  op data-matrix : BFS -> Matrix
  op initial-point : BFS -> DataPoint
  op target-point : BFS -> DataPoint
  
  vars M : Matrix .
  vars IP TP : DataPoint .
  eq data-matrix(bfs(M, IP, TP)) = M .
  eq initial-point(bfs(M, IP, TP)) = IP .
  eq target-point(bfs(M, IP, TP)) = TP .

  -- Helper function to insert into a sorted list (PriorityQueue.put)
  op put : DataPoint List{DataPoint} -> List{DataPoint}
  var E : DataPoint .
  var Q : List{DataPoint} .
  eq put(E, nil) = E :: nil .
  eq put(E, Q) = if E < head(Q) then E :: Q else head(Q) :: put(E, tail(Q)) fi .

  -- Helper function to check membership in processed list
  op is-processed? : NatPair List{NatPair} -> Bool
  var C : NatPair .
  var PL : List{NatPair} .
  eq is-processed?(C, nil) = false .
  eq is-processed?(C, C :: PL) = true .
  eq is-processed?(C, head(PL) :: tail(PL)) = is-processed?(C, tail(PL)) .

  -- insert_element method
  op insert-element : DataPoint Float Float DataPoint -> DataPoint
  var E CE : DataPoint .
  vars WA WB : Float .
  eq insert-element(E, WA, WB, CE) = dataPoint(coordinates(E), WA, WB, WA + WB, CE) .

  -- swap_elements method
  op swap-elements : BFS DataPoint -> Float
  var B : BFS .
  var E : DataPoint .
  eq swap-elements(B, E) = toFloat(abs(x(coordinates(E)) - x(coordinates(target-point(B)))))
                         + toFloat(abs(y(coordinates(E)) - y(coordinates(target-point(B))))) .

  -- reverse_string method
  op reverse-string : BFS DataPoint -> List{DataPoint}
  var B : BFS .
  var E : DataPoint .
  op get-adj : BFS NatPair List{NatPair} -> List{DataPoint}
  var C : NatPair .
  var DIRS : List{NatPair} .
  eq reverse-string(B, E) = get-adj(B, coordinates(E), < 1, 0 > :: < 0, 1 > :: < -1, 0 > :: < 0, -1 > :: nil) .
  eq get-adj(B, C, nil) = nil .
  eq get-adj(B, C, DIRS) = 
    let adjacent-coords = < toNat(toInt(x(C)) + x(head(DIRS))), toNat(toInt(y(C)) + y(head(DIRS))) > .
    if (0 <= toInt(x(adjacent-coords))) and (toInt(x(adjacent-coords)) < shape0(data-matrix(B))) and
       (0 <= toInt(y(adjacent-coords))) and (toInt(y(adjacent-coords)) < shape1(data-matrix(B))) and
       (data-matrix(B)[adjacent-coords] != -1)
    then
      dataPoint(adjacent-coords, 0.0, 0.0, 0.0, null-dp) :: get-adj(B, C, tail(DIRS))
    else
      get-adj(B, C, tail(DIRS))
    fi .

  -- calculate_sum method
  op calculate-sum : DataPoint List{DataPoint} -> DataPoint
  var E : DataPoint .
  var Q : List{DataPoint} .
  eq calculate-sum(E, nil) = null-dp .
  eq calculate-sum(E, Q) = if coordinates(E) == coordinates(head(Q))
                           then head(Q)
                           else calculate-sum(E, tail(Q))
                           fi .

  -- find_list method
  op find-list : BFS DataPoint -> List{NatPair}
  op find-list-aux : BFS DataPoint -> List{NatPair}
  var B : BFS .
  var FE CE : DataPoint .
  eq find-list(B, FE) = reverse(find-list-aux(B, FE)) .
  eq find-list-aux(B, CE) =
    if coordinates(CE) == coordinates(initial-point(B)) then
      coordinates(initial-point(B)) :: nil
    else
      coordinates(CE) :: find-list-aux(B, predecessor(CE))
    fi .

  -- Helper to replace an element in the queue (for the mutation logic)
  op replace-in-queue : DataPoint DataPoint List{DataPoint} -> List{DataPoint}
  var OLD NEW : DataPoint .
  var Q : List{DataPoint} .
  eq replace-in-queue(OLD, NEW, nil) = nil .
  eq replace-in-queue(OLD, NEW, Q) =
    if coordinates(OLD) == coordinates(head(Q)) then
      NEW :: tail(Q)
    else
      head(Q) :: replace-in-queue(OLD, NEW, tail(Q))
    fi .

  -- Inner loop (over adjacent elements) logic
  op process-adjacents : BFS DataPoint List{DataPoint} List{NatPair} List{DataPoint} -> List{DataPoint}
  var B : BFS .
  var CUR : DataPoint .
  var PEND-Q : List{DataPoint} .
  var PROC : List{NatPair} .
  var ADJ : List{DataPoint} .
  eq process-adjacents(B, CUR, PEND-Q, PROC, nil) = PEND-Q .
  eq process-adjacents(B, CUR, PEND-Q, PROC, ADJ) =
    let element = head(ADJ) .
    if is-processed?(coordinates(element), PROC) then
      process-adjacents(B, CUR, PEND-Q, PROC, tail(ADJ))
    else
      let weight-a = weight-a(CUR) + toFloat(data-matrix(B)[coordinates(element)]) .
      let weight-b = swap-elements(B, element) .
      let existing-element = calculate-sum(element, PEND-Q) .
      if existing-element == null-dp then
        let new-element = insert-element(element, weight-a, weight-b, CUR) .
        process-adjacents(B, CUR, put(new-element, PEND-Q), PROC, tail(ADJ))
      else
        if weight-a < weight-a(existing-element) then
          let updated-element = insert-element(existing-element, weight-a, weight-b, CUR) .
          process-adjacents(B, CUR, replace-in-queue(existing-element, updated-element, PEND-Q), PROC, tail(ADJ))
        else
          process-adjacents(B, CUR, PEND-Q, PROC, tail(ADJ))
        fi
      fi
    fi .

  -- Main `while` loop logic, implemented recursively
  op execute-loop : BFS List{DataPoint} List{NatPair} -> PathResult
  var B : BFS .
  var PEND-Q : List{DataPoint} .
  var PROC : List{NatPair} .
  eq execute-loop(B, nil, PROC) = no-path .
  eq execute-loop(B, PEND-Q, PROC) =
    let current-element = head(PEND-Q) .
    let rest-queue = tail(PEND-Q) .
    if is-processed?(coordinates(current-element), PROC) then
      execute-loop(B, rest-queue, PROC)
    else
      let new-processed = coordinates(current-element) :: PROC .
      if coordinates(current-element) == coordinates(target-point(B)) then
        path-found(find-list(B, current-element), total-weight(current-element))
      else
        let adjacent-elements = reverse-string(B, current-element) .
        let new-queue = process-adjacents(B, current-element, rest-queue, new-processed, adjacent-elements) .
        execute-loop(B, new-queue, new-processed)
      fi
    fi .
  
  -- execute method
  op execute : BFS -> PathResult
  var B : BFS .
  eq execute(B) = execute-loop(B, put(initial-point(B), nil), nil) .
}

-- Main execution block
open BFS-LOGIC .

-- The map grid
op map-grid : -> Matrix .
eq map-grid = matrix(
    (0 :: 2 :: -1 :: 0 :: 2 :: 6 :: 5 :: 5 :: 4 :: 6 :: nil) ::
    (5 :: -1 :: -1 :: 4 :: 1 :: 1 :: 1 :: 5 :: 3 :: 5 :: nil) ::
    (2 :: 6 :: 8 :: -1 :: 5 :: 2 :: 8 :: 4 :: 0 :: 0 :: nil) ::
    (1 :: 0 :: 5 :: 5 :: -1 :: 2 :: 2 :: 1 :: 0 :: 7 :: nil) ::
    (0 :: 6 :: 5 :: 0 :: 6 :: 6 :: 7 :: 6 :: 0 :: 1 :: nil) ::
    (4 :: 3 :: 8 :: 7 :: 3 :: 4 :: 8 :: 6 :: 4 :: 2 :: nil) ::
    (1 :: 3 :: 5 :: 2 :: 6 :: 2 :: 4 :: 6 :: 8 :: 1 :: nil) ::
    (2 :: 8 :: 0 :: 5 :: 7 :: 1 :: 6 :: -1 :: 8 :: 1 :: nil) ::
    (7 :: 5 :: 0 :: 2 :: 4 :: -1 :: 0 :: 3 :: 0 :: 5 :: nil) ::
    (3 :: 3 :: 6 :: 0 :: 6 :: 5 :: 7 :: 4 :: 6 :: 5 :: nil) ::
    nil
) .

-- Start and goal nodes
op start-node : -> DataPoint .
op goal-node : -> DataPoint .
eq start-node = dataPoint(< 0, 0 >, 0.0, 0.0, 0.0, null-dp) .
eq goal-node = dataPoint(< 9, 9 >, 0.0, 0.0, 0.0, null-dp) .

-- BFS instance
op my-bfs : -> BFS .
eq my-bfs = bfs(map-grid, start-node, goal-node) .

-- Execution
-- red execute(my-bfs) .
-- The above `red` command would be used in a CafeObj interpreter to run the code.
-- Expected output would be a `path-found` term containing the list of coordinates and the final weight.
close

-- Model: gemini/gemini-2.5-pro
-- Temperature: 0.7
-- Response Time: 99900 ms
-- Timestamp: 9/12/2025, 1:05:26 PM
-- Prompt Tokens: 1727
-- Completion Tokens: 11597
-- Total Tokens: 13324
-- Cost: $0.1181