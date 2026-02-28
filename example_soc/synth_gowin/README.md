# Hazard3 example SoC — Tang Nano 9K (Gowin GW1NR-9C)

## 必要なツール

| ツール | 用途 |
|---|---|
| [Gowin EDA](https://www.gowinsemi.com/en/support/download_eda/) | 合成・配置配線 (`gw_sh`) |
| [openFPGALoader](https://github.com/trabucayre/openFPGALoader) | ビットストリーム書き込み |
| `riscv64-unknown-elf-gcc` (rv32im 対応) | ファームウェアのクロスコンパイル |
| [OpenOCD](https://openocd.org/) | JTAG デバッグ |

---

## ビルドと書き込み

```bash
cd example_soc/synth_gowin

# 合成（ファームウェアのビルドも自動実行）
make synth

# ビットストリームを SRAM に書き込む（電源断で消える）
make run

# ビットストリームを Flash に書き込む（永続）
make flash
```

### クリーン

```bash
# 合成成果物のみ削除（ファームウェア hex は保持・RTL 修正時に使用）
make clean-synth

# 全て削除（ファームウェア含む）
make clean
```

---

## ハードウェア接続

### JTAG（PMOD0 経由）

JTAG デバッグには外部 JTAG アダプタを PMOD0 に接続します。

#### FT232H（Adafruit FT232H Breakout など、推奨）

| FT232H ピン | 信号 | Tang Nano 9K FPGA ピン |
|---|---|---|
| AD0 (D0) | TCK | 28 |
| AD1 (D1) | TDI → | 26 |
| AD2 (D2) | TDO ← | 39 |
| AD3 (D3) | TMS | 37 |
| GND | GND | GND |

OpenOCD 設定: `example_soc/tangnano9k-ft232h-openocd.cfg`

#### FT2232H（FT2232H Mini Module など）

| FT2232H チャンネル A ピン | 信号 | Tang Nano 9K FPGA ピン |
|---|---|---|
| ADBUS0 (AD0) | TCK | 28 |
| ADBUS1 (AD1) | TDI → | 26 |
| ADBUS2 (AD2) | TDO ← | 39 |
| ADBUS3 (AD3) | TMS | 37 |
| GND | GND | GND |

OpenOCD 設定: `example_soc/tangnano9k-openocd.cfg`

> **PMOD0 スペア**: FPGA ピン 27（未使用）

---

### UART（PMOD1 経由）

PMOD1 に USB-UART アダプタを接続します。

| 信号 | Tang Nano 9K FPGA ピン | USB-UART アダプタ |
|---|---|---|
| TX（FPGA 送信） | 33 | RX |
| RX（FPGA 受信） | 30 | TX |
| GND | GND | GND |

ボーレート: `115200`（ソフトウェアで設定可能）

---

## JTAG デバッグ

### OpenOCD 起動

```bash
# FT232H の場合
openocd -f example_soc/tangnano9k-ft232h-openocd.cfg

# FT2232H の場合
openocd -f example_soc/tangnano9k-openocd.cfg
```

接続成功時の出力例:

```
Info : JTAG tap: hazard3.cpu tap/device found: ...
Info : [hazard3.cpu] datacount=2 progbufsize=8
Info : [hazard3.cpu] Examined RISC-V core; found 1 harts
Info : starting gdb server for hazard3.cpu on 3333
```

### GDB 接続

別ターミナルで:

```bash
riscv64-unknown-elf-gdb

(gdb) target extended-remote :3333
(gdb) info registers
(gdb) x/10i $pc        # 現在の PC 周辺の逆アセンブル表示
(gdb) continue
(gdb) Ctrl-C           # 停止
```

GDB の ELF を指定してシンボル情報付きでデバッグする場合:

```bash
riscv64-unknown-elf-gdb example_soc/sw/tangnano9k/blink.elf

(gdb) target extended-remote :3333
(gdb) load              # プログラムを SRAM にロード
(gdb) break main
(gdb) continue
```

---

## プリロードファームウェア

合成時に `sw/tangnano9k/blink.elf` のバイナリが SRAM の初期値として埋め込まれます。
電源投入直後から CPU が実行を開始し、LED がバウンスパターンで点滅します（GPIO アドレス: `0x4000_8000`）。

ファームウェアを変更した場合は再合成が必要です:

```bash
# ファームウェアを再ビルドして再合成
make -C ../sw/tangnano9k
make clean-synth
make synth
```

---

## メモリマップ

| アドレス | サイズ | 用途 |
|---|---|---|
| `0x0000_0000` | 32 KB | SRAM（コード・データ） |
| `0x4000_0000` | - | タイマ（APB） |
| `0x4000_4000` | - | UART（APB） |
| `0x4000_8000` | - | GPIO 出力（APB、bit[5:0] → LED[5:0]） |

- リセットベクタ: `0x0000_0040`
- トラップベクタ (mtvec): `0x0000_0000`
