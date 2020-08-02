import time
from pprint import pprint

def solver():
    T = int(input())
    dictionary = dict()
    
    for i in range(T):
        print("Case {}:".format(i + 1))
        N, Q = [int(i) for i in input().split()]

        for _ in range(N):
            split_item = input().split()
            unique_subsequence = set()
            for i in range(len(split_item)):
                for j in range(i + 1, len(split_item) + 1):
                    subsequence = " ".join(split_item[i:j])
                    unique_subsequence.add(subsequence)
            
            for subsequence in unique_subsequence:
                if subsequence not in dictionary:
                    dictionary[subsequence] = 0
                dictionary[subsequence] += 1
        pprint(dictionary)
        # for _ in range(Q):
        #     query = input()
        #     if query in dictionary:
        #         print(dictionary[query])
        #     else:
        #         print(0)

if __name__ == "__main__":
    start_time = time.time()
    solver()
    print("Completed in: {:.4f}s".format(time.time() - start_time))