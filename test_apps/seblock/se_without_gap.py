from typing import Callable, List, Optional

import torch
from torch import Tensor

import argparse

class SqueezeExcitation(torch.nn.Module):
  """
  This block implements the Squeeze-and-Excitation block from https://arxiv.org/abs/1709.01507 (see Fig. 1).
  Parameters ``activation``, and ``scale_activation`` correspond to ``delta`` and ``sigma`` in in eq. 3.
  Args:
    input_channels (int): Number of channels in the input image
    squeeze_channels (int): Number of squeeze channels
    activation (Callable[..., torch.nn.Module], optional): ``delta`` activation. Default: ``torch.nn.ReLU``
    scale_activation (Callable[..., torch.nn.Module]): ``sigma`` activation. Default: ``torch.nn.Sigmoid``
  """
  def __init__(
    self,
    input_channels: int = 32,
    squeeze_channels: int = 32,
    activation: Callable[..., torch.nn.Module] = torch.nn.ReLU,
    scale_activation: Callable[..., torch.nn.Module] = torch.nn.Sigmoid,
  ) -> None:
    super().__init__()
    self.fc1 = torch.nn.Conv2d(input_channels, squeeze_channels, 1)
    self.fc2 = torch.nn.Conv2d(squeeze_channels, input_channels, 1)
    self.activation = activation()
    self.scale_activation = scale_activation()

  def _scale(self, input: Tensor) -> Tensor:
    scale = self.fc1(input)
    scale = self.activation(scale)
    scale = self.fc2(scale)
    return self.scale_activation(scale)

  def forward(self, input: Tensor) -> Tensor:
    scale = self._scale(input)
    return scale * input

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument("--channel")
  args = parser.parse_args()
  
  device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
  print(f"using {device} device")
  x = torch.randn(1, int(args.channel), 1, 1).to(device)
  model = SqueezeExcitation(int(args.channel), int(args.channel)).to(device)
  output = model(x)
  print(output.size())
