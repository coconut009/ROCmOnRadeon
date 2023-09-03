#!/bin/bash

CURDIR=$(pwd)
LOGFILE="log_pyt_microbenchmarking_fp32"

# Run the Python code and capture the output
output=$(python3 -c 'import torch; print(torch.cuda.is_available())')
# if CUDA interface is not ready exit 
# Check if the output is true
if [[ "$output" != "True" ]]; then
    echo "CUDA interface is not available. Exiting..."
    echo "Please check you environment setup..."
    exit 1
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


start_time=$(date +%s)
end_time=$((start_time + $runtime * 60))

echo "Starting benchmark..."
read -p "Enter the number of GPUs to run the command: " num_gpus

# Check if the input is a valid integer
if ! [[ "$num_gpus" =~ ^[0-9]+$ && "$num_gpus" -ge 1 ]]; then
    echo "Invalid input: $num_gpus"
    exit 1
fi

# Generate a comma-separated list of device IDs
device_ids=$(seq -s, 0 $((num_gpus-1)))

# Run the benchmark with the specified device IDs
script_start_time=$(date +%Y%m%d-%H%M%S)
python3 micro_benchmarking_pytorch.py --device_ids=$device_ids --network resnet50 --dataparallel --batch-size 128 --iterations 100 --fp16 0 |& tee -a $LOGFILE-$start_time.txt
script_end_time=$(date +%Y%m%d-%H%M%S)
echo "FP32 ResNet50 training Start time: $script_start_time" >> $LOGFILE-$start_time.txt
echo "FP32 ResNet50 End time: $script_end_time" >> $LOGFILE-$start_time.txt