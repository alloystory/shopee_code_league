import time

def solver():
    def floydWarshall(graph):
        dist = graph.copy()
        for k in range(N): 
            for i in range(N): 
                for j in range(N): 
                    dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])

    def printr(d):
        print("[")
        for i in d:
            print(i)
        print("]")

    N = int(input())
    dist = []
    for i in range(N):
        dist.append([99999]*N)
        
    for i in range(N - 1):
        hub_one, hub_two, hub_length = [int(j) for j in input().split()]
        dist[hub_one - 1][hub_two - 1] = hub_length
        dist[hub_two - 1][hub_one - 1] = hub_length

    printr(dist)
    floydWarshall(dist)

    printr(dist)
    
        
if __name__ == "__main__":
    start_time = time.time()
    solver()
    print("Completed in: {:.4f}s".format(time.time() - start_time))


    # V = 4 

    # INF  = 99999
    
    # # Solves all pair shortest path via Floyd Warshall Algorithm 
    

    # graph = [[0,5,INF,10], 
    #             [INF,0,3,INF], 
    #             [INF, INF, 0,   1], 
    #             [INF, INF, INF, 0] 
    #         ] 
    # # Print the solution 
    # floydWarshall(graph); 
    # # This code is contributed by Nikhil Kumar Singh(nickzuck_007) 