mod! DATA-POINT {
  [Coord]
  op [_,_,_,_,_] : Coord Float Float Float DataPoint? -> DataPoint
  op coordinates : DataPoint -> Coord
  op weight_a : DataPoint -> Float
  op weight_b : DataPoint -> Float
  op total_weight : DataPoint -> Float
  op predecessor : DataPoint -> DataPoint?
}

mod! PRIORITY-QUEUE {
  protecting(LIST[DataPoint] * { sort List -> PriorityQueue })
  op empty : -> PriorityQueue
  op put : DataPoint PriorityQueue -> PriorityQueue
  op get : PriorityQueue -> DataPoint PriorityQueue
  op empty? : PriorityQueue -> Bool
}

mod! BFS {
  protecting(PRIORITY-QUEUE)
  protecting(LIST[Coord])
  protecting(MATRIX[Int])
  op bfs : PriorityQueue List Matrix DataPoint DataPoint -> Pair
  op execute : Matrix DataPoint DataPoint -> Pair
  op reverse-string : DataPoint Matrix -> List
  op swap-elements : DataPoint DataPoint -> Float
  op find-list : DataPoint DataPoint -> List
  op insert-element : DataPoint Float Float DataPoint -> DataPoint
  op calculate-sum : DataPoint PriorityQueue -> DataPoint?
}

mod! MAIN {
  protecting(BFS)
  op run : -> Pair
}

-- DataPoint module implementation
eq coordinates([C,WA,WB,TW,P]) = C .
eq weight_a([C,WA,WB,TW,P]) = WA .
eq weight_b([C,WA,WB,TW,P]) = WB .
eq total_weight([C,WA,WB,TW,P]) = TW .
eq predecessor([C,WA,WB,TW,P]) = P .

-- PriorityQueue module implementation
eq empty = nil .
eq put(X,Q) = insert(X,Q) .
eq get(nil) = nil .
eq get(X Q) = if empty?(Q) then X else if total_weight(X) < total_weight(head(Q)) then X else get(Q) fi fi .
eq empty?(nil) = true .
eq empty?(X Q) = false .

-- BFS module implementation
eq execute(M,IP,TP) = bfs(put(IP,empty),nil,M,IP,TP) .

eq bfs(Q,P,M,IP,TP) =
  if empty?(Q) then nil
  else let C = get(Q) in
    if (coordinates(C) in P) then bfs(remove(C,Q),P,M,IP,TP)
    else let NP = append(P,coordinates(C)) in
      if coordinates(C) == coordinates(TP) then (find-list(C,IP), total_weight(C))
      else let ADJ = reverse-string(C,M) in
        process-adjacent(ADJ,C,Q,NP,M,IP,TP)
      fi
    fi
  fi .

op process-adjacent : List DataPoint PriorityQueue List Matrix DataPoint DataPoint -> Pair .
eq process-adjacent(nil,C,Q,P,M,IP,TP) = bfs(Q,P,M,IP,TP) .
eq process-adjacent(A AS,C,Q,P,M,IP,TP) =
  if coordinates(A) in P then process-adjacent(AS,C,Q,P,M,IP,TP)
  else let WA = weight_a(C) + M[coordinates(A)] in
    let WB = swap-elements(A,TP) in
      case calculate-sum(A,Q) of
        nothing -> let NA = insert-element(A,WA,WB,C) in
          process-adjacent(AS,C,put(NA,Q),P,M,IP,TP)
        | just E -> if WA < weight_a(E) then
            let NE = insert-element(E,WA,WB,C) in
              process-adjacent(AS,C,replace(E,NE,Q),P,M,IP,TP)
          else process-adjacent(AS,C,Q,P,M,IP,TP)
          fi
      esac
  fi .

eq reverse-string(E,M) = 
  [ [1,0], [0,1], [-1,0], [0,-1] ] >> (
    lambda D . let AC = (coord-x(coordinates(E)) + head(D), coord-y(coordinates(E)) + head(tail(D))) in
      if (0 <= coord-x(AC) and coord-x(AC) < nrow(M)) and (0 <= coord-y(AC) and coord-y(AC) < ncol(M)) then
        if M[AC] != -1 then [AC,0,0,0,nothing] else nil fi
      else nil
    fi
  ) .

eq swap-elements(E,TP) = abs(coord-x(coordinates(E)) - coord-x(coordinates(TP))) + abs(coord-y(coordinates(E)) - coord-y(coordinates(TP))) .

eq find-list(F,IP) =
  if predecessor(F) == nothing then [coordinates(F)]
  else if coordinates(predecessor(F)) == coordinates(IP) then [coordinates(IP), coordinates(F)]
  else append(find-list(predecessor(F),IP), [coordinates(F)])
  fi .

eq insert-element(E,WA,WB,P) = [coordinates(E),WA,WB,WA+WB,just(P)] .

eq calculate-sum(E,nil) = nothing .
eq calculate-sum(E,X Q) = if coordinates(X) == coordinates(E) then just(X) else calculate-sum(E,Q) fi .

-- Main module
eq run = execute(
  matrix(
    [0,2,-1,0,2,6,5,5,4,6],
    [5,-1,-1,4,1,1,1,5,3,5],
    [2,6,8,-1,5,2,8,4,0,0],
    [1,0,5,5,-1,2,2,1,0,7],
    [0,6,5,0,6,6,7,6,0,1],
    [4,3,8,7,3,4,8,6,4,2],
    [1,3,5,2,6,2,4,6,8,1],
    [2,8,0,5,7,1,6,-1,8,1],
    [7,5,0,2,4,-1,0,3,0,5],
    [3,3,6,0,6,5,7,4,6,5]
  ),
  [(0,0),0,0,0,nothing],
  [(9,9),0,0,0,nothing]
) .
-- Model: deepseek/deepseek-reasoner
-- Temperature: 0.7
-- Response Time: 195060 ms
-- Timestamp: 9/10/2025, 10:26:30 PM
-- Prompt Tokens: 1486
-- Completion Tokens: 3757
-- Total Tokens: 5243
-- Cost: $0.0090