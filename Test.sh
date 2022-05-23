#!/bin/bash

while getopts g: flag
do
	echo ${OPTARG} 
done