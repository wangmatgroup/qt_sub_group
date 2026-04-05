#!/bin/bash
# extract_photoelastic.sh
# Run this from the parent directory containing linear-x, linear-y, linear-z, etc.
# 
# Each log file contains 3 dielectric tensors (equilibrium, +strain, -strain)
# in order: DS14, DS24, DS34
#
# Usage: bash extract_photoelastic.sh

DELTA=0.01  # strain magnitude

# Map directories to Voigt strain indices
# eta1=x, eta2=y, eta3=z, eta4=yz, eta5=xz, eta6=xy
declare -A DIRS
DIRS[1]="linear-x"
DIRS[2]="linear-y"
DIRS[3]="linear-z"
DIRS[4]="linear-yz"
DIRS[5]="linear-xz"
DIRS[6]="linear-xy"

echo "============================================"
echo "  Photoelastic Tensor Extraction for AlN"
echo "============================================"
echo ""
echo "Strain magnitude delta = $DELTA"
echo ""

# For each strain direction (Voigt index beta = 1..6)
for beta in 1 2 3 4 5 6; do
    dir=${DIRS[$beta]}
    
    # Find the log/abo file
    logfile=$(ls ${dir}/*.abo 2>/dev/null | head -1)
    if [ -z "$logfile" ]; then
        logfile=$(ls ${dir}/*.log 2>/dev/null | head -1)
    fi
    
    if [ -z "$logfile" ]; then
        echo "WARNING: No log file found in ${dir}/, skipping eta_${beta}"
        continue
    fi
    
    echo "--- Strain direction beta=$beta (${dir}) ---"
    echo "    Log file: $logfile"
    
    python3 << PYEOF
import re

logfile = "${logfile}"
delta = ${DELTA}
beta = ${beta}

# Read the file
with open(logfile, 'r') as f:
    content = f.read()

# Find all dielectric tensor blocks
blocks = content.split("Dielectric tensor, in cartesian coordinates,")

if len(blocks) < 4:
    print(f"  ERROR: Found only {len(blocks)-1} dielectric tensors, expected 3")
else:
    tensors = []
    for i in range(1, 4):  # blocks 1,2,3
        block = blocks[i]
        lines = block.strip().split('\n')
        eps = [[0.0]*3 for _ in range(3)]
        count = 0
        for line in lines:
            parts = line.split()
            if len(parts) >= 6:
                try:
                    row = int(parts[0]) - 1
                    col = int(parts[2]) - 1
                    val = float(parts[4])
                    if 0 <= row < 3 and 0 <= col < 3:
                        eps[row][col] = val
                        count += 1
                except (ValueError, IndexError):
                    continue
            if count >= 9:
                break
        tensors.append(eps)
    
    labels = ["equilibrium", "+strain", "-strain"]
    
    for idx, (eps, label) in enumerate(zip(tensors, labels)):
        print(f"  {label}:")
        print(f"    eps_11={eps[0][0]:.10f}  eps_22={eps[1][1]:.10f}  eps_33={eps[2][2]:.10f}")
        if abs(eps[0][1]) > 1e-6 or abs(eps[0][2]) > 1e-6 or abs(eps[1][2]) > 1e-6:
            print(f"    OFF-DIAG: eps_12={eps[0][1]:.10f}  eps_13={eps[0][2]:.10f}  eps_23={eps[1][2]:.10f}")
    
    print()
    
    eps_plus = tensors[1]
    eps_minus = tensors[2]
    
    print(f"  Photoelastic tensor column beta={beta}:")
    
    # Diagonal components p_{alpha,beta} for alpha=1,2,3
    for alpha_idx, alpha_label in enumerate(["p_1", "p_2", "p_3"]):
        B_plus = 1.0 / eps_plus[alpha_idx][alpha_idx]
        B_minus = 1.0 / eps_minus[alpha_idx][alpha_idx]
        p_val = (B_plus - B_minus) / (2.0 * delta)
        print(f"    {alpha_label}{beta} = ({B_plus:.10f} - {B_minus:.10f}) / {2*delta} = {p_val:.6f}")
    
    # Off-diagonal impermeability components for shear strains
    # B_ij = -eps_ij / (eps_ii * eps_jj) for small off-diagonal eps
    # p_4beta from B_23, p_5beta from B_13, p_6beta from B_12
    offdiag_map = [(1,2, "p_4"), (0,2, "p_5"), (0,1, "p_6")]
    for i, j, label in offdiag_map:
        eps_ij_plus = eps_plus[i][j]
        eps_ii_plus = eps_plus[i][i]
        eps_jj_plus = eps_plus[j][j]
        B_ij_plus = -eps_ij_plus / (eps_ii_plus * eps_jj_plus)
        
        eps_ij_minus = eps_minus[i][j]
        eps_ii_minus = eps_minus[i][i]
        eps_jj_minus = eps_minus[j][j]
        B_ij_minus = -eps_ij_minus / (eps_ii_minus * eps_jj_minus)
        
        p_val = (B_ij_plus - B_ij_minus) / (2.0 * delta)
        if abs(p_val) > 1e-8:
            print(f"    {label}{beta} = {p_val:.6f}")
        else:
            print(f"    {label}{beta} = {p_val:.6f}  (≈0, as expected by symmetry)")
    
    print()
PYEOF

done

echo "============================================"
echo "  Key components for r33_piezo:"
echo "  r33_piezo = 2*p31*d13 + p33*d33"
echo "  p31 comes from column beta=1 (x-strain)"
echo "  p33 comes from column beta=3 (z-strain)"
echo "============================================"
