""" Import modules usually used in data-science tasks. """


try: import numpy as np
except ModuleNotFoundError: pass
try: import pandas as pd
except ModuleNotFoundError: pass
try: import matplotlib.pyplot as plt
except ModuleNotFoundError: pass
try: import seaborn as sns
except ModuleNotFoundError: pass
try: import tqdm.tqdm as tqdm
except ModuleNotFoundError: pass

# pytorch modules
try: import torch
except ModuleNotFoundError: pass
try: import torch.nn as nn
except ModuleNotFoundError: pass
try: import torch.optim as optim
except ModuleNotFoundError: pass
try: import torch.nn.functional as F
except ModuleNotFoundError: pass
try: import torchtext
except ModuleNotFoundError: pass
try: import torchvision
except ModuleNotFoundError: pass
try: import torchaudio
except ModuleNotFoundError: pass

try: import gym
except ModuleNotFoundError: pass


if __name__ == '__main__':
	pass
