from multiprocessing import Pool
from pathlib import Path
from functools import partial
import inspect
import time

def parallel_task(func, iterable, len_iterable = None, *params):
    print("Parallelising task...")
    start_time = time.time()
    
    tmp_filepath = Path("./tmp_func.py")
    with tmp_filepath.open("w") as tmp_file:
        tmp_file.write(inspect.getsource(func).replace(func.__name__, "task"))

    from tmp_func import task
    output = []
    count = 0
    
    print("Running task in parallel...")
    if params:
        task = partial(task, params)

    with Pool() as p:
        for res in p.imap(task, iterable):
            output.append(res)
            count += 1
            elapsed_time = time.time() - start_time
            avg_time = elapsed_time / count
            
            if len_iterable:
                percent_completed = count / len_iterable * 100
                print("Completed: {:.2f}% {}/{} in {:.2f}s. Avg Time: {:.4f}s/item"
                    .format(percent_completed, count, len_iterable, elapsed_time, avg_time), end = "\r")
            else:
                print("Completed: {} in {:.2f}s. Avg Time: {:.4f}s/item".format(count, elapsed_time, avg_time), end = "\r")
        print()
    print("Finished running task")
    
    tmp_filepath.unlink()
    return output