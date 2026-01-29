#!/usr/bin/env python3
"""
NeuroAccess - Parkinson's Disease Detection Model Training
STORY-007: ML Model Training - Baseline

This script trains a feedforward neural network on the UCI Parkinson's dataset
to detect Parkinson's disease from voice features.

Dataset: UCI Machine Learning Repository - Parkinson's Dataset
Features: 22 biomedical voice measurements
Target: status (1 = Parkinson's, 0 = Healthy)

Author: Junho Lee
Date: 2026-01-27
"""

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime

# TensorFlow
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, regularizers
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint, ReduceLROnPlateau

# Scikit-learn
from sklearn.model_selection import train_test_split, StratifiedKFold
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    confusion_matrix, classification_report, roc_curve, auc
)

# Set random seeds for reproducibility
np.random.seed(42)
tf.random.set_seed(42)

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(BASE_DIR)
DATA_PATH = os.path.join(PROJECT_DIR, 'data', 'raw', 'parkinsons.data')
OUTPUT_DIR = os.path.join(BASE_DIR, 'outputs')
MODEL_DIR = os.path.join(PROJECT_DIR, 'mobile_app', 'assets', 'models')

# Create output directories
os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(MODEL_DIR, exist_ok=True)


def load_and_preprocess_data(data_path: str) -> tuple:
    """
    Load UCI Parkinson's dataset and preprocess for training.
    
    Returns:
        X: Feature matrix (n_samples, n_features)
        y: Target vector (n_samples,)
        feature_names: List of feature names
    """
    print("=" * 60)
    print("STEP 1: Loading and Preprocessing Data")
    print("=" * 60)
    
    # Load dataset
    df = pd.read_csv(data_path)
    print(f"\nDataset shape: {df.shape}")
    print(f"Columns: {list(df.columns)}")
    
    # Display dataset info
    print(f"\nClass distribution:")
    print(df['status'].value_counts())
    print(f"  - Parkinson's (1): {df['status'].sum()} samples ({df['status'].mean()*100:.1f}%)")
    print(f"  - Healthy (0): {len(df) - df['status'].sum()} samples ({(1-df['status'].mean())*100:.1f}%)")
    
    # Drop 'name' column (patient identifier)
    df = df.drop('name', axis=1)
    
    # Separate features and target
    X = df.drop('status', axis=1).values
    y = df['status'].values
    feature_names = df.drop('status', axis=1).columns.tolist()
    
    print(f"\nFeature matrix shape: {X.shape}")
    print(f"Target vector shape: {y.shape}")
    print(f"Number of features: {len(feature_names)}")
    
    return X, y, feature_names


def explore_data(X: np.ndarray, y: np.ndarray, feature_names: list) -> None:
    """Generate exploratory data analysis visualizations."""
    print("\n" + "=" * 60)
    print("STEP 2: Exploratory Data Analysis")
    print("=" * 60)
    
    # Create DataFrame for visualization
    df = pd.DataFrame(X, columns=feature_names)
    df['status'] = y
    
    # Feature statistics
    print("\nFeature Statistics:")
    print(df.describe().T)
    
    # Save correlation heatmap
    plt.figure(figsize=(16, 14))
    corr_matrix = df.corr()
    mask = np.triu(np.ones_like(corr_matrix, dtype=bool))
    sns.heatmap(corr_matrix, mask=mask, cmap='coolwarm', center=0,
                annot=False, square=True, linewidths=0.5)
    plt.title("Feature Correlation Matrix", fontsize=14)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'correlation_matrix.png'), dpi=150)
    plt.close()
    print("\n✓ Correlation matrix saved to outputs/correlation_matrix.png")
    
    # Feature distributions by class
    fig, axes = plt.subplots(5, 5, figsize=(20, 16))
    axes = axes.flatten()
    
    for idx, col in enumerate(feature_names[:25]):
        if idx < len(axes):
            ax = axes[idx]
            df[df['status'] == 0][col].hist(ax=ax, alpha=0.5, label='Healthy', bins=15)
            df[df['status'] == 1][col].hist(ax=ax, alpha=0.5, label="Parkinson's", bins=15)
            ax.set_title(col, fontsize=8)
            ax.legend(fontsize=6)
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'feature_distributions.png'), dpi=150)
    plt.close()
    print("✓ Feature distributions saved to outputs/feature_distributions.png")


def prepare_data_splits(X: np.ndarray, y: np.ndarray) -> tuple:
    """
    Split data into train/validation/test sets and normalize.
    
    Split ratio: 70% train, 15% validation, 15% test
    """
    print("\n" + "=" * 60)
    print("STEP 3: Data Splitting and Normalization")
    print("=" * 60)
    
    # First split: 70% train, 30% temp
    X_train, X_temp, y_train, y_temp = train_test_split(
        X, y, test_size=0.30, random_state=42, stratify=y
    )
    
    # Second split: 50% of temp for validation, 50% for test (15% each of total)
    X_val, X_test, y_val, y_test = train_test_split(
        X_temp, y_temp, test_size=0.50, random_state=42, stratify=y_temp
    )
    
    print(f"\nData splits:")
    print(f"  Training:   {X_train.shape[0]} samples ({X_train.shape[0]/len(X)*100:.1f}%)")
    print(f"  Validation: {X_val.shape[0]} samples ({X_val.shape[0]/len(X)*100:.1f}%)")
    print(f"  Test:       {X_test.shape[0]} samples ({X_test.shape[0]/len(X)*100:.1f}%)")
    
    # Normalize features using StandardScaler
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_val_scaled = scaler.transform(X_val)
    X_test_scaled = scaler.transform(X_test)
    
    print(f"\n✓ Features normalized (StandardScaler)")
    print(f"  Mean (train): {X_train_scaled.mean():.6f}")
    print(f"  Std (train):  {X_train_scaled.std():.6f}")
    
    # Save scaler for later use
    import joblib
    scaler_path = os.path.join(OUTPUT_DIR, 'scaler.joblib')
    joblib.dump(scaler, scaler_path)
    print(f"✓ Scaler saved to {scaler_path}")
    
    return (X_train_scaled, X_val_scaled, X_test_scaled, 
            y_train, y_val, y_test, scaler)


def build_model(input_dim: int) -> keras.Model:
    """
    Build feedforward neural network for Parkinson's detection.
    
    Architecture:
    - Input: 22 features (from UCI dataset)
    - Hidden Layer 1: 64 neurons, ReLU, BatchNorm, Dropout(0.3)
    - Hidden Layer 2: 32 neurons, ReLU, BatchNorm, Dropout(0.3)
    - Hidden Layer 3: 16 neurons, ReLU
    - Output: 1 neuron, Sigmoid
    """
    print("\n" + "=" * 60)
    print("STEP 4: Building Neural Network Model")
    print("=" * 60)
    
    model = keras.Sequential([
        # Input layer
        layers.Input(shape=(input_dim,), name='input'),
        
        # Hidden layer 1
        layers.Dense(64, activation='relu', 
                    kernel_regularizer=regularizers.l2(0.001),
                    name='dense_1'),
        layers.BatchNormalization(name='bn_1'),
        layers.Dropout(0.3, name='dropout_1'),
        
        # Hidden layer 2
        layers.Dense(32, activation='relu',
                    kernel_regularizer=regularizers.l2(0.001),
                    name='dense_2'),
        layers.BatchNormalization(name='bn_2'),
        layers.Dropout(0.3, name='dropout_2'),
        
        # Hidden layer 3
        layers.Dense(16, activation='relu',
                    kernel_regularizer=regularizers.l2(0.001),
                    name='dense_3'),
        
        # Output layer
        layers.Dense(1, activation='sigmoid', name='output')
    ], name='parkinson_detector')
    
    # Compile model
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss='binary_crossentropy',
        metrics=['accuracy', 
                keras.metrics.Precision(name='precision'),
                keras.metrics.Recall(name='recall'),
                keras.metrics.AUC(name='auc')]
    )
    
    print("\nModel Architecture:")
    model.summary()
    
    return model


def train_model(model: keras.Model, 
                X_train: np.ndarray, y_train: np.ndarray,
                X_val: np.ndarray, y_val: np.ndarray) -> keras.callbacks.History:
    """
    Train the neural network with early stopping and learning rate reduction.
    """
    print("\n" + "=" * 60)
    print("STEP 5: Training Model")
    print("=" * 60)
    
    # Callbacks
    callbacks = [
        EarlyStopping(
            monitor='val_auc',
            patience=20,
            mode='max',
            restore_best_weights=True,
            verbose=1
        ),
        ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=10,
            min_lr=1e-6,
            verbose=1
        ),
        ModelCheckpoint(
            filepath=os.path.join(OUTPUT_DIR, 'best_model.keras'),
            monitor='val_auc',
            mode='max',
            save_best_only=True,
            verbose=1
        )
    ]
    
    # Handle class imbalance with class weights
    n_total = len(y_train)
    n_positive = y_train.sum()
    n_negative = n_total - n_positive
    
    class_weights = {
        0: n_total / (2 * n_negative),
        1: n_total / (2 * n_positive)
    }
    print(f"\nClass weights: {class_weights}")
    
    # Train
    print(f"\nTraining configuration:")
    print(f"  Epochs: 100 (with early stopping)")
    print(f"  Batch size: 16")
    print(f"  Optimizer: Adam (lr=0.001)")
    print(f"  Loss: Binary Cross-Entropy")
    print()
    
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=100,
        batch_size=16,
        class_weight=class_weights,
        callbacks=callbacks,
        verbose=1
    )
    
    return history


def plot_training_history(history: keras.callbacks.History) -> None:
    """Plot training and validation metrics over epochs."""
    print("\n" + "=" * 60)
    print("STEP 6: Visualizing Training History")
    print("=" * 60)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Loss
    axes[0, 0].plot(history.history['loss'], label='Train')
    axes[0, 0].plot(history.history['val_loss'], label='Validation')
    axes[0, 0].set_title('Loss')
    axes[0, 0].set_xlabel('Epoch')
    axes[0, 0].set_ylabel('Loss')
    axes[0, 0].legend()
    axes[0, 0].grid(True)
    
    # Accuracy
    axes[0, 1].plot(history.history['accuracy'], label='Train')
    axes[0, 1].plot(history.history['val_accuracy'], label='Validation')
    axes[0, 1].set_title('Accuracy')
    axes[0, 1].set_xlabel('Epoch')
    axes[0, 1].set_ylabel('Accuracy')
    axes[0, 1].legend()
    axes[0, 1].grid(True)
    
    # AUC
    axes[1, 0].plot(history.history['auc'], label='Train')
    axes[1, 0].plot(history.history['val_auc'], label='Validation')
    axes[1, 0].set_title('AUC-ROC')
    axes[1, 0].set_xlabel('Epoch')
    axes[1, 0].set_ylabel('AUC')
    axes[1, 0].legend()
    axes[1, 0].grid(True)
    
    # Precision & Recall
    axes[1, 1].plot(history.history['precision'], label='Train Precision')
    axes[1, 1].plot(history.history['val_precision'], label='Val Precision')
    axes[1, 1].plot(history.history['recall'], label='Train Recall')
    axes[1, 1].plot(history.history['val_recall'], label='Val Recall')
    axes[1, 1].set_title('Precision & Recall')
    axes[1, 1].set_xlabel('Epoch')
    axes[1, 1].set_ylabel('Score')
    axes[1, 1].legend()
    axes[1, 1].grid(True)
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'training_history.png'), dpi=150)
    plt.close()
    
    print("✓ Training history saved to outputs/training_history.png")


def evaluate_model(model: keras.Model, 
                   X_test: np.ndarray, y_test: np.ndarray) -> dict:
    """
    Evaluate model on test set and generate comprehensive report.
    """
    print("\n" + "=" * 60)
    print("STEP 7: Evaluating Model on Test Set")
    print("=" * 60)
    
    # Predictions
    y_pred_proba = model.predict(X_test, verbose=0).flatten()
    y_pred = (y_pred_proba >= 0.5).astype(int)
    
    # Metrics
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred)
    recall = recall_score(y_test, y_pred)  # Sensitivity
    f1 = f1_score(y_test, y_pred)
    
    # Specificity (recall for class 0)
    tn, fp, fn, tp = confusion_matrix(y_test, y_pred).ravel()
    specificity = tn / (tn + fp)
    
    # AUC-ROC
    fpr, tpr, thresholds = roc_curve(y_test, y_pred_proba)
    roc_auc = auc(fpr, tpr)
    
    metrics = {
        'accuracy': accuracy,
        'precision': precision,
        'sensitivity': recall,  # Same as recall
        'specificity': specificity,
        'f1_score': f1,
        'auc_roc': roc_auc
    }
    
    print("\n📊 Test Set Performance:")
    print("-" * 40)
    print(f"  Accuracy:    {accuracy*100:.2f}%")
    print(f"  Precision:   {precision*100:.2f}%")
    print(f"  Sensitivity: {recall*100:.2f}% (Recall)")
    print(f"  Specificity: {specificity*100:.2f}%")
    print(f"  F1 Score:    {f1*100:.2f}%")
    print(f"  AUC-ROC:     {roc_auc:.4f}")
    
    # Target metrics check
    print("\n🎯 Target vs Achieved:")
    print("-" * 40)
    targets = {'Accuracy': 85, 'Sensitivity': 85, 'Specificity': 80, 'AUC-ROC': 0.90}
    achieved = {'Accuracy': accuracy*100, 'Sensitivity': recall*100, 
                'Specificity': specificity*100, 'AUC-ROC': roc_auc}
    
    for metric, target in targets.items():
        val = achieved[metric]
        if metric == 'AUC-ROC':
            status = "✅" if val >= target else "❌"
            print(f"  {metric}: {val:.4f} (target: ≥{target}) {status}")
        else:
            status = "✅" if val >= target else "❌"
            print(f"  {metric}: {val:.2f}% (target: ≥{target}%) {status}")
    
    # Classification report
    print("\n📋 Classification Report:")
    print(classification_report(y_test, y_pred, 
                               target_names=['Healthy', "Parkinson's"]))
    
    # Confusion Matrix
    print("📊 Confusion Matrix:")
    cm = confusion_matrix(y_test, y_pred)
    print(f"  TN={tn}, FP={fp}")
    print(f"  FN={fn}, TP={tp}")
    
    # Plot confusion matrix
    plt.figure(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                xticklabels=['Healthy', "Parkinson's"],
                yticklabels=['Healthy', "Parkinson's"])
    plt.title('Confusion Matrix')
    plt.xlabel('Predicted')
    plt.ylabel('Actual')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'confusion_matrix.png'), dpi=150)
    plt.close()
    
    # Plot ROC curve
    plt.figure(figsize=(8, 6))
    plt.plot(fpr, tpr, color='darkorange', lw=2, 
             label=f'ROC curve (AUC = {roc_auc:.4f})')
    plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('Receiver Operating Characteristic (ROC) Curve')
    plt.legend(loc="lower right")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'roc_curve.png'), dpi=150)
    plt.close()
    
    print("\n✓ Confusion matrix saved to outputs/confusion_matrix.png")
    print("✓ ROC curve saved to outputs/roc_curve.png")
    
    return metrics


def save_model(model: keras.Model, feature_names: list, metrics: dict) -> str:
    """
    Save trained model in H5 format for later conversion to TFLite.
    """
    print("\n" + "=" * 60)
    print("STEP 8: Saving Model")
    print("=" * 60)
    
    # Save in H5 format
    model_path = os.path.join(OUTPUT_DIR, 'parkinson_model_v1.0.h5')
    model.save(model_path)
    print(f"✓ Model saved to: {model_path}")
    
    # Save Keras format (recommended)
    keras_path = os.path.join(OUTPUT_DIR, 'parkinson_model_v1.0.keras')
    model.save(keras_path)
    print(f"✓ Model saved to: {keras_path}")
    
    # Save model metadata
    metadata = {
        'model_name': 'NeuroAccess Parkinson Detector',
        'version': '1.0',
        'date_trained': datetime.now().isoformat(),
        'input_features': feature_names,
        'input_shape': [1, len(feature_names)],
        'output_shape': [1, 1],
        'metrics': metrics,
        'framework': f'TensorFlow {tf.__version__}',
        'python_version': f'{os.sys.version_info.major}.{os.sys.version_info.minor}'
    }
    
    import json
    metadata_path = os.path.join(OUTPUT_DIR, 'model_metadata.json')
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    print(f"✓ Metadata saved to: {metadata_path}")
    
    # Model size
    model_size_mb = os.path.getsize(model_path) / (1024 * 1024)
    print(f"\nModel size: {model_size_mb:.2f} MB")
    
    return model_path


def convert_to_tflite(model_path: str) -> str:
    """
    Convert trained model to TensorFlow Lite format with INT8 quantization.
    """
    print("\n" + "=" * 60)
    print("STEP 9: Converting to TensorFlow Lite")
    print("=" * 60)
    
    # Load the model
    model = keras.models.load_model(model_path)
    
    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Apply optimizations
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]
    
    # Convert
    tflite_model = converter.convert()
    
    # Save TFLite model
    tflite_path = os.path.join(MODEL_DIR, 'parkinson_model_v1.0.tflite')
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    # Also save to outputs for comparison
    tflite_output_path = os.path.join(OUTPUT_DIR, 'parkinson_model_v1.0.tflite')
    with open(tflite_output_path, 'wb') as f:
        f.write(tflite_model)
    
    # Model sizes
    h5_size = os.path.getsize(model_path) / 1024
    tflite_size = os.path.getsize(tflite_path) / 1024
    
    print(f"\n✓ TFLite model saved to: {tflite_path}")
    print(f"\nModel Size Comparison:")
    print(f"  H5 model:     {h5_size:.2f} KB")
    print(f"  TFLite model: {tflite_size:.2f} KB")
    print(f"  Reduction:    {(1 - tflite_size/h5_size)*100:.1f}%")
    
    return tflite_path


def validate_tflite_model(tflite_path: str, X_test: np.ndarray, y_test: np.ndarray) -> None:
    """
    Validate TFLite model accuracy against the original model.
    """
    print("\n" + "=" * 60)
    print("STEP 10: Validating TFLite Model")
    print("=" * 60)
    
    # Load TFLite model
    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()
    
    # Get input/output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"\nTFLite Model Details:")
    print(f"  Input shape:  {input_details[0]['shape']}")
    print(f"  Input dtype:  {input_details[0]['dtype']}")
    print(f"  Output shape: {output_details[0]['shape']}")
    print(f"  Output dtype: {output_details[0]['dtype']}")
    
    # Run inference on test set
    predictions = []
    for sample in X_test:
        input_data = sample.astype(np.float32).reshape(1, -1)
        interpreter.set_tensor(input_details[0]['index'], input_data)
        interpreter.invoke()
        output = interpreter.get_tensor(output_details[0]['index'])
        predictions.append(output[0][0])
    
    y_pred_proba = np.array(predictions)
    y_pred = (y_pred_proba >= 0.5).astype(int)
    
    # Calculate metrics
    accuracy = accuracy_score(y_test, y_pred)
    recall = recall_score(y_test, y_pred)
    tn, fp, fn, tp = confusion_matrix(y_test, y_pred).ravel()
    specificity = tn / (tn + fp)
    
    print(f"\n📊 TFLite Model Performance:")
    print(f"  Accuracy:    {accuracy*100:.2f}%")
    print(f"  Sensitivity: {recall*100:.2f}%")
    print(f"  Specificity: {specificity*100:.2f}%")
    
    # Check acceptance criteria
    print("\n✅ TFLite Conversion Validation:")
    print(f"  Accuracy ≥80%: {'✅' if accuracy >= 0.80 else '❌'}")
    print(f"  Sensitivity ≥80%: {'✅' if recall >= 0.80 else '❌'}")
    print(f"  Specificity ≥75%: {'✅' if specificity >= 0.75 else '❌'}")


def generate_report(metrics: dict, feature_names: list) -> None:
    """Generate final training report in Markdown format."""
    print("\n" + "=" * 60)
    print("STEP 11: Generating Training Report")
    print("=" * 60)
    
    report = f"""# NeuroAccess - Model Training Report

**Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Model Version**: 1.0  
**Framework**: TensorFlow {tf.__version__}

---

## Dataset Information

- **Source**: UCI Machine Learning Repository - Parkinson's Dataset
- **Total Samples**: 195
- **Features**: {len(feature_names)} voice measurements
- **Classes**: Binary (0=Healthy, 1=Parkinson's)
- **Class Distribution**: ~75% Parkinson's, ~25% Healthy

## Model Architecture

| Layer | Type | Neurons | Activation | Regularization |
|-------|------|---------|------------|----------------|
| Input | Dense | {len(feature_names)} | - | - |
| Hidden 1 | Dense | 64 | ReLU | L2(0.001), Dropout(0.3) |
| Hidden 2 | Dense | 32 | ReLU | L2(0.001), Dropout(0.3) |
| Hidden 3 | Dense | 16 | ReLU | L2(0.001) |
| Output | Dense | 1 | Sigmoid | - |

## Training Configuration

- **Optimizer**: Adam (lr=0.001)
- **Loss**: Binary Cross-Entropy
- **Batch Size**: 16
- **Max Epochs**: 100 (with early stopping)
- **Data Split**: 70% train / 15% validation / 15% test

## Performance Metrics

| Metric | Target | Achieved | Status |
|--------|--------|----------|--------|
| Accuracy | ≥85% | {metrics['accuracy']*100:.2f}% | {'✅' if metrics['accuracy'] >= 0.85 else '❌'} |
| Sensitivity | ≥85% | {metrics['sensitivity']*100:.2f}% | {'✅' if metrics['sensitivity'] >= 0.85 else '❌'} |
| Specificity | ≥80% | {metrics['specificity']*100:.2f}% | {'✅' if metrics['specificity'] >= 0.80 else '❌'} |
| AUC-ROC | ≥0.90 | {metrics['auc_roc']:.4f} | {'✅' if metrics['auc_roc'] >= 0.90 else '❌'} |

## Output Files

- `parkinson_model_v1.0.h5` - TensorFlow model
- `parkinson_model_v1.0.tflite` - Mobile-optimized model
- `scaler.joblib` - Feature scaler for preprocessing
- `model_metadata.json` - Model metadata
- `training_history.png` - Training curves
- `confusion_matrix.png` - Test set confusion matrix
- `roc_curve.png` - ROC curve

## Feature List

{chr(10).join([f'{i+1}. `{f}`' for i, f in enumerate(feature_names)])}

---

*Generated by NeuroAccess ML Pipeline*
"""
    
    report_path = os.path.join(OUTPUT_DIR, 'training_report.md')
    with open(report_path, 'w') as f:
        f.write(report)
    
    print(f"✓ Training report saved to: {report_path}")


def main():
    """Main training pipeline."""
    print("\n" + "=" * 60)
    print("🧠 NeuroAccess - Parkinson's Detection Model Training")
    print("=" * 60)
    print(f"TensorFlow version: {tf.__version__}")
    print(f"Start time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Step 1: Load data
    X, y, feature_names = load_and_preprocess_data(DATA_PATH)
    
    # Step 2: EDA
    explore_data(X, y, feature_names)
    
    # Step 3: Prepare data splits
    (X_train, X_val, X_test, 
     y_train, y_val, y_test, scaler) = prepare_data_splits(X, y)
    
    # Step 4: Build model
    model = build_model(input_dim=X_train.shape[1])
    
    # Step 5: Train model
    history = train_model(model, X_train, y_train, X_val, y_val)
    
    # Step 6: Plot training history
    plot_training_history(history)
    
    # Step 7: Evaluate model
    metrics = evaluate_model(model, X_test, y_test)
    
    # Step 8: Save model
    model_path = save_model(model, feature_names, metrics)
    
    # Step 9: Convert to TFLite
    tflite_path = convert_to_tflite(model_path)
    
    # Step 10: Validate TFLite model
    validate_tflite_model(tflite_path, X_test, y_test)
    
    # Step 11: Generate report
    generate_report(metrics, feature_names)
    
    print("\n" + "=" * 60)
    print("✅ Training Pipeline Complete!")
    print("=" * 60)
    print(f"\nEnd time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"\nOutput directory: {OUTPUT_DIR}")
    print(f"TFLite model: {tflite_path}")


if __name__ == '__main__':
    main()
