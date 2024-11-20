from multiprocessing import Pool
import os
import time

def test_function(arg):
    print(f"Process {os.getpid()} received argument: {arg}")
    time.sleep(2)

if __name__ == "__main__":
    args = [(i,) for i in range(4)]  # Sample arguments for testing
    with Pool(4) as pool:
        pool.map(test_function, args)
