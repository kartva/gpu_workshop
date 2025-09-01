#!/usr/bin/env python3
"""
Train a 4-layer MLP on MNIST and save weights for the GPU workshop.

Architecture: 784 → 256 → 128 → 64 → 10
Activations: ReLU after layers 1-3, no activation after layer 4

Run once to produce mnist_mlp_weights.pt, then host for participants.
"""

import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, transforms
from torch.utils.data import DataLoader


class MnistMLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.fc1 = nn.Linear(784, 256)
        self.fc2 = nn.Linear(256, 128)
        self.fc3 = nn.Linear(128, 64)
        self.fc4 = nn.Linear(64, 10)
        self.relu = nn.ReLU()

    def forward(self, x):
        x = x.view(-1, 784)  # Flatten 28x28 → 784
        x = self.relu(self.fc1(x))
        x = self.relu(self.fc2(x))
        x = self.relu(self.fc3(x))
        x = self.fc4(x)  # No activation on final layer (logits)
        return x


def train():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Training on: {device}")

    transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize((0.1307,), (0.3081,))
    ])

    train_dataset = datasets.MNIST(
        root="./data", train=True, download=True, transform=transform
    )
    test_dataset = datasets.MNIST(
        root="./data", train=False, download=True, transform=transform
    )

    train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True)
    test_loader = DataLoader(test_dataset, batch_size=1000, shuffle=False)

    model = MnistMLP().to(device)
    optimizer = optim.Adam(model.parameters(), lr=1e-3)
    criterion = nn.CrossEntropyLoss()

    epochs = 10
    for epoch in range(1, epochs + 1):
        model.train()
        total_loss = 0
        for batch_idx, (data, target) in enumerate(train_loader):
            data, target = data.to(device), target.to(device)
            optimizer.zero_grad()
            output = model(data)
            loss = criterion(output, target)
            loss.backward()
            optimizer.step()
            total_loss += loss.item()

        avg_loss = total_loss / len(train_loader)

        model.eval()
        correct = 0
        with torch.no_grad():
            for data, target in test_loader:
                data, target = data.to(device), target.to(device)
                output = model(data)
                pred = output.argmax(dim=1)
                correct += pred.eq(target).sum().item()

        accuracy = 100.0 * correct / len(test_dataset)
        print(f"Epoch {epoch}/{epochs} | Loss: {avg_loss:.4f} | Test Accuracy: {accuracy:.2f}%")

    weights = {
        "fc1.weight": model.fc1.weight.data.cpu(),
        "fc1.bias": model.fc1.bias.data.cpu(),
        "fc2.weight": model.fc2.weight.data.cpu(),
        "fc2.bias": model.fc2.bias.data.cpu(),
        "fc3.weight": model.fc3.weight.data.cpu(),
        "fc3.bias": model.fc3.bias.data.cpu(),
        "fc4.weight": model.fc4.weight.data.cpu(),
        "fc4.bias": model.fc4.bias.data.cpu(),
    }

    output_path = "mnist_mlp_weights.pt"
    torch.save(weights, output_path)
    print(f"\nWeights saved to {output_path}")
    print("\nWeight shapes:")
    for name, tensor in weights.items():
        print(f"  {name}: {tuple(tensor.shape)}")


if __name__ == "__main__":
    train()
