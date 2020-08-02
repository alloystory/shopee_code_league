import time
from pprint import pprint

def solver():
    def rec(lst, looking_for = 1, index = 0, curr_max = -1, max_index = -1):
        if index == len(lst):
            return curr_max, max_index

        height = lst[index]
        if height == looking_for:
            if height > curr_max:
                return rec(lst, looking_for + 1, index + 1, height, index)
            else:
                return rec(lst, looking_for + 1, index + 1, curr_max, max_index)
        else:
            return rec(lst, 1, index + 1, curr_max, max_index)

    N = int(input())
    for i in range(N):
        input()
        L = int(input())
        mountain_heights = [int(j) for j in input().split()]
        rev_mountain_heights = mountain_heights.copy()
        rev_mountain_heights.reverse()

        max_height, max_index = rec(mountain_heights.copy())
        rev_max_height, rev_max_index = rec(rev_mountain_heights.copy())

        if rev_max_height > max_height:
            max_height = rev_max_height
            max_index = len(mountain_heights) - rev_max_index - 1

        print("Case #{}: {} {}".format(i + 1, max_height, max_index))

if __name__ == "__main__":
    start_time = time.time()
    solver()
    print("Completed in: {:.4f}s".format(time.time() - start_time))