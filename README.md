
# EEG-Based Preference Prediction

A comparative analysis of **Band-Pass Filtering (BPF)** and **Discrete Wavelet Transform (DWT)** for EEG-based product preference prediction.

## Overview

This project processes EEG signals from 12 subjects to distinguish between preferred and non-preferred products. The workflow includes EEG preprocessing, signal segmentation, feature extraction, and machine learning-based classification.

## Methodology

* EEG preprocessing using EEGLAB
* Signal segmentation using BPF and DWT
* Extraction of EEG frequency bands and statistical features
* Calculation of Awareness and Valence indices
* Classification using Decision Tree, SVM, Neural Network, KNN, and Ensemble Learning

## Results

* **Best BPF Accuracy:** 90.6% using Neural Network
* **Best DWT Accuracy:** 93.8% using SVM

The results indicate that **DWT-based preprocessing with SVM achieved the highest classification accuracy of 93.8%**.

## Technologies

**MATLAB | EEGLAB | EEG Signal Processing | Machine Learning**
