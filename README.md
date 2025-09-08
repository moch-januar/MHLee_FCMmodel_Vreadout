
# FCM Readout: From Circuit Concept to Complete Voltage Expression

This repository provides a MATLAB implementation of a **multi‑level ferroelectric capacitive memory (FCM)** readout driven by a **charge‑amplifier topology** with feedback capacitor $C_{\rm REF}$, an *optional* parallel resistor $R_L$, and a small constant bleed current $I_{\rm bleed}$. Each memory state $k$ is represented by a capacitor $C_k$. The read sequence is:

1) **Pre‑charge** the cell to $V_R$  
2) **Connect** the cell at time $t_0$, producing an instantaneous “jump” at the output due to charge sharing  
3) **Discharge** the output under the action of $I_{\rm bleed}$ and (optionally) $R_L$  
4) **Sample** at $t_{\rm read}$ and place decision thresholds

---

## 1) Circuit & Assumptions

**Topology (conceptual).** The non‑inverting op‑amp input is grounded ($V_+=0$), so the inverting node is held near 0 V (**virtual ground**). Feedback is provided by $C_{\rm REF}$ with an optional $R_L$ in parallel from $V_o$ to the inverting node. During read, the FCM state capacitor $C_k$ is switched to the inverting node. A small, nearly constant $I_{\rm bleed}$ injects/sinks current to produce a linear ramp component.

**Idealizations.**  
- Ideal op‑amp (infinite gain, zero input current) $\Rightarrow$ KCL at the inverting node, node voltage $\approx 0$ V  
- Unit step $u(x)=1$ for $x\ge 0$, else $0$, marks event onsets  
- A small front‑end settling time $t_{\rm set}$ models finite jump settling

---

## 2) Pre‑Charge: Initial Conditions

For $t_{\rm pre}\le t \le t_0$, the cell is driven to $V_R$ while the inverting node is at virtual ground. Just before connection:

$$
Q_k^- = C_k V_R, \qquad V_o^- = 0 \;\Rightarrow\; Q_{\rm REF}^- = 0.
$$

---

## 3) Instant of Connection ($t=t_0$): Output “Jump”

Enforcing charge conservation at the inverting node (held at 0 V) gives the post‑switch output:

$$
\boxed{V_{0k} \equiv V_o^+ = \frac{C_k}{C_{\rm REF}}\,V_R}
$$

To emulate finite front‑end settling in the figure, we multiply by

$$
\mathrm{shape}(t) = \big(1-e^{-(t-t_0)/t_{\rm set}}\big)\,u(t-t_0).
$$

---

## 4) Post‑Connection Dynamics

For $t>t_0$, the cell current is $\approx 0$, and KCL at the inverting node reads:

$$
C_{\rm REF}\,\frac{dV_o}{dt} + \frac{V_o}{R_L} + I_{\rm bleed} = 0, \qquad
\tau_{RC}=R_L C_{\rm REF}.
$$

### Case A — Pure Bleed ($R_L=\infty$)

$$
V_o(t)=V_{0k} - \frac{I_{\rm bleed}}{C_{\rm REF}}\,(t-t_0)
$$

### Case B — Pure $R_L$ ($I_{\rm bleed}=0$)

$$
V_o(t)= V_{0k}\,e^{-(t-t_0)/\tau_{RC}}
$$

### General Case — Exact Solution

$$
\boxed{V_o^{\rm exact}(t)= \big(V_{0k}+I_{\rm bleed}R_L\big)\,e^{-\frac{t-t_0}{\tau_{RC}}} - I_{\rm bleed}R_L}
$$

---

## 5) Superposition Implementation

The code assembles the waveform as

$$
V_o^{(k)}(t)= V_{0k}\,\mathrm{shape}(t) + \mathrm{dec}_{\rm lin}(t) + \mathrm{dec}_{RC,k}(t)
$$

This matches the limits: pure linear ($R_L=\infty$) and pure exponential ($I_{\rm bleed}=0$).

---

## 6) Readout and Thresholds

At chosen $t_{\rm read}$:

$$
v_{\rm read}^{(k)} = V_o^{(k)}(t_{\rm read})
$$

Decision thresholds:

$$
T_i = \frac{v_{(i)}+v_{(i+1)}}{2}
$$

---

## 7) Code Mapping

| Concept        | Equation                                                                 | Code |
|----------------|--------------------------------------------------------------------------|------|
| Jump           | $V_{0k}=\frac{C_k}{C_{\rm REF}}V_R$                                     | `Vo0k = (C(k)/Cref) * VR;` |
| Finite settle  | $\mathrm{shape}(t)=(1-e^{-(t-t_0)/t_{\rm set}})\,u(t-t_0)$               | `shape = (1-exp(-(t - t0)/t_set)).*u(t - t0);` |
| Linear bleed   | $\mathrm{dec}_{\rm lin}= -\frac{I_{\rm bleed}}{C_{\rm REF}}(t-t_0)\,u(t-t_0)$ | `dec_lin = -(Ibleed/Cref) * (t - t0) .* u;` |
| $R_L$ leakage  | $\mathrm{dec}_{RC,k}=V_{0k}\left(e^{-\frac{t-t_0}{\tau_{RC}}}-1\right)u(t-t_0)$ | `dec_rc_k = Vo0k * (exp(-(t - t0)/tauRC) - 1) .* u(t - t0);` |
| Total          | $V_o^{(k)}=V_{0k}\,\mathrm{shape}+\mathrm{dec}_{\rm lin}+\mathrm{dec}_{RC,k}$ | `Vo(k,:) = max(VoJk + dec_lin + dec_rc_k, 0);` |

---

## 8) Parameters

| Parameter | NUS (literature) | Our Data |
|---|---:|---:|
| Device area $A$ (cm²) | $2.2\times10^{-5}$ | $2.1\times10^{-4}$ |
| $C_{\rm ref}$ (pF) | 10 | 12 |
| $R_L$ (Ω) | $\infty$ | $\infty$ |
| $I_{\rm bleed}$ (nA) | 18 | 10 |
| $t_{\rm end}$ (ms) | 0.70 | 2750 |
| $dt$ (µs) | 0.5 | 0.5 |
| $\eta$ (–) | 1.0 | 0.16 |
| $V_R$ (V) | 0.5 | 0.5 |
| $t_0$ (ms) | 0.12 | 0.12 |

---

## 9) Quick Start

Edit top of script:

```matlab
Cref = 10e-12;     % F
RL   = 100e6;      % Ohm
Ibleed = 18e-9;    % A
t_end = 2.0;       % s
```

Then run: see pre‑charge, jumps, discharge, thresholds.

---

## License

MIT License — see LICENSE.
