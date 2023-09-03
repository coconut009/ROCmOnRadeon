#!/bin/bash

# Run the Python code and capture the output
output=$(python3 -c 'import torch; print(torch.cuda.is_available())')
# if CUDA interface is not ready exit 
# Check if the output is true
if [[ "$output" != "True" ]]; then
    echo "CUDA interface is not available. Exiting..."
    echo "Please check you environment setup..."
    exit 1
fi

CURDIR=$(pwd)
LOGFILE="log_pyt_microbenchmarking_fp16"

# Check pip version
current_version=$(pip --version | awk '{print $2}')
echo "Current pip version: $current_version"

# Check if pip needs to be updated
latest_version=$(pip install --upgrade pip &>/dev/null && pip --version | awk '{print $2}')
if [[ $latest_version != $current_version ]]; then
    echo "Updating pip to version $latest_version"
    pip install --upgrade pip
else
    echo "pip is already up to date."
fi

if [ -d "$CURDIR/pytorch-micro-benchmarking" ]; then
    echo "pytorch micro benchmarking repo already exists"
    cd $CURDIR/pytorch-micro-benchmarking
    if git diff-index --quiet HEAD --; then
        echo "Contents accurate"
    else 
        echo "Contents missing"
        cd ..
        rm -rf $CURDIR/pytorch-micro-benchmarking
        git clone https://github.com/ROCmSoftwarePlatform/pytorch-micro-benchmarking.git
        cd pytorch-micro-benchmarking
    fi
else
    git clone https://github.com/ROCmSoftwarePlatform/pytorch-micro-benchmarking.git
    if [ $? -eq 0 ]; then
        echo "pytorch micro benchmarking repo successfully cloned"
    else
        echo "Error: Failed cloning"
        exit 1
    fi
    cd pytorch-micro-benchmarking
fi

python3 micro_benchmarking_pytorch.py --network resnet50 --batch-size 128 --iterations 10 --fp16 1 2>&1 | tee -a $LOGFILE-$start_time.txt
python3 micro_benchmarking_pytorch.py --network resnet101 --batch-size 64 --iterations 10 --fp16 1 2>&1| tee -a $LOGFILE-$start_time.txt
python3 micro_benchmarking_pytorch.py --network resnet152 --batch-size 64 --iterations 10 --fp16 1 2>&1| tee -a $LOGFILE-$start_time.txt
python3 micro_benchmarking_pytorch.py --network alexnet --batch-size 512 --iterations 10 --fp16 1 2>&1| tee -a $LOGFILE-$start_time.txt
python3 micro_benchmarking_pytorch.py --network SqueezeNet --batch-size 64 --iterations 10 --fp16 1 2>&1| tee -a $LOGFILE-$start_time.txt
python3 micro_benchmarking_pytorch.py --network inception_v3 --batch-size 128 --iterations 10 --fp16 1 2>&1| tee -a $LOGFILE-$start_time.txt
python3 micro_benchmarking_pytorch.py --network densenet121 --batch-size 64 --iterations 10 --fp16 1 2>&1| tee -a $LOGFILE-$start_time.txt
python3 micro_benchmarking_pytorch.py --network vgg16 --batch-size 64 --iterations 10 --fp16 1 2>&1| tee -a $LOGFILE-$start_time.txt
python3 micro_benchmarking_pytorch.py --network vgg19 --batch-size 64 --iterations 10 --fp16 1 2>&1| tee -a $LOGFILE-$start_time.txt
python3 micro_benchmarking_pytorch.py --network resnext50 --batch-size 16  --iterations 10 --fp16 1 2>&1| tee -a $LOGFILE-$start_time.txt