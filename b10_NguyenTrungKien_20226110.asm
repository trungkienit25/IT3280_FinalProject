# Check not pressing. If all rows return $a0 == 0, update {code} = 0.
# If {code} == 0, run `back_to_polling`.

# Check pressing. If pressed && $a0 != $s0, run `code_processing`.
# Run `process_code` to get key's value && switch mode.

# Mode 1: If old {operator} is "=", remove old info. Update {operand}, output new {operand}.
# Mode 2: If old {operator} doesn't change, do nothing.
# Else, update {operator}, update {answer} = {operand}, output old {operand}, remove old {operand}.
# Mode 3: Update {answer} = {answer} {operator} {operand}, update {operator}, update {operand} = {answer}, output new {answer}.

.eqv SEVENSEG_LEFT	0xFFFF0011
.eqv SEVENSEG_RIGHT	0xFFFF0010
.eqv IN_ADDRESS_HEXA_KEYBOARD       0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD      0xFFFF0014
.eqv CODE_0							0x11
.eqv CODE_1							0x21
.eqv CODE_2							0x41
.eqv CODE_3							0x81
.eqv CODE_4							0x12
.eqv CODE_5							0x22
.eqv CODE_6							0x42
.eqv CODE_7							0x82
.eqv CODE_8							0x14
.eqv CODE_9							0x24
.eqv CODE_ADD						0x44
.eqv CODE_SUB						0x84
.eqv CODE_MUL						0x18
.eqv CODE_DIV						0x28
.eqv CODE_MOD						0x48
.eqv CODE_EQL						0x88
.data
NUMS:	.word		0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
.text
main:
    li      $t1,            IN_ADDRESS_HEXA_KEYBOARD
    li      $t2,            OUT_ADDRESS_HEXA_KEYBOARD
start:
    li      $s0,            0                                               # Mã code của phím được nhấn.
    li      $s1,            0                                               # Lưu trữ giá trị thực của phím được nhấn (0 -> 15).
    li      $s2,            0                                               # Chế độ hiện tại của chương trình. (1, 2, 3)
    li      $s3,            0                                               # Toán hạng của phép tính.
    li      $s4,            0                                               # Toán tử.
    li      $s5,            0                                               # Lưu trữ kết quả của phép tính trước đó.
polling:
check_row_1:
    li      $t3,            0x01                                            # Check 0, 1, 2, 3 (hàng 1 của bàn phím)
    sb      $t3,            0($t1)                                          # Lưu giá trị hàng cần kiểm tra vào $t1
    lbu     $a0,            0($t2)                                          # Đọc mã quét từ bàn phím
    beq     $a0,            0,                          check_row_2         # Nếu không có phím nào được nhấn, chuyển sang kiểm tra hàng tiếp theo
    bne     $a0,            $s0,                        code_processing     # Nếu mã quét khác với mã trước đó, cập nhật mã
    beq     $a0,            $s0,                        back_to_polling     # Nếu mã quét giống mã trước đó, quay lại vòng lặp kiểm tra
check_row_2:
    li      $t3,            0x02                                            # Check 4, 5, 6, 7
    sb      $t3,            0($t1)                                          # Lưu giá trị hàng cần kiểm tra vào $t1
    lbu     $a0,            0($t2)                                          # Đọc mã quét từ bàn phím
    beq     $a0,            0,                          check_row_3
    bne     $a0,            $s0,                        code_processing
    beq     $a0,            $s0,                        back_to_polling
check_row_3:
    li      $t3,            0x04                                            # Check 8, 9, a, b
    sb      $t3,            0($t1)                                          # Lưu giá trị hàng cần kiểm tra vào $t1
    lbu     $a0,            0($t2)                                          # Đọc mã quét từ bàn phím
    beq     $a0,            0,                          check_row_4
    bne     $a0,            $s0,                        code_processing
    beq     $a0,            $s0,                        back_to_polling
check_row_4:
    li      $t3,            0x08                                            # Check c, d, e, f
    sb      $t3,            0($t1)                                          # Lưu giá trị hàng cần kiểm tra vào $t1
    lbu     $a0,            0($t2)                                          # Đọc mã quét từ bàn phím
    beq     $a0,            0,                          code_processing
    bne     $a0,            $s0,                        code_processing
    beq     $a0,            $s0,                        back_to_polling
code_processing:
    add     $s0,            $zero,                      $a0
    beq     $s0,            0,                          back_to_polling
    beq     $s0,            CODE_0,                     process_code_0
    beq     $s0,            CODE_1,                     process_code_1
    beq     $s0,            CODE_2,                     process_code_2
    beq     $s0,            CODE_3,                     process_code_3
    beq     $s0,            CODE_4,                     process_code_4
    beq     $s0,            CODE_5,                     process_code_5
    beq     $s0,            CODE_6,                     process_code_6
    beq     $s0,            CODE_7,                     process_code_7
    beq     $s0,            CODE_8,                     process_code_8
    beq     $s0,            CODE_9,                     process_code_9
    beq     $s0,            CODE_ADD,                   process_code_add
    beq     $s0,            CODE_SUB,                   process_code_sub
    beq     $s0,            CODE_MUL,                   process_code_mul
    beq     $s0,            CODE_DIV,                   process_code_div
    beq     $s0,            CODE_MOD,                   process_code_mod
    beq     $s0,            CODE_EQL,                   process_code_eql
process_code_0:
    li      $s1,            0
    li      $s2,            1
    j       after_processing_code
process_code_1:
    li      $s1,            1
    li      $s2,            1
    j       after_processing_code
process_code_2:
    li      $s1,            2
    li      $s2,            1
    j       after_processing_code
process_code_3:
    li      $s1,            3
    li      $s2,            1
    j       after_processing_code
process_code_4:
    li      $s1,            4
    li      $s2,            1
    j       after_processing_code
process_code_5:
    li      $s1,            5
    li      $s2,            1
    j       after_processing_code
process_code_6:
    li      $s1,            6
    li      $s2,            1
    j       after_processing_code
process_code_7:
    li      $s1,            7
    li      $s2,            1
    j       after_processing_code
process_code_8:
    li      $s1,            8
    li      $s2,            1
    j       after_processing_code
process_code_9:
    li      $s1,            9
    li      $s2,            1
    j       after_processing_code
process_code_add:
    li      $s1,            10
    li      $s2,            2
    j       after_processing_code
process_code_sub:
    li      $s1,            11
    li      $s2,            2
    j       after_processing_code
process_code_mul:
    li      $s1,            12
    li      $s2,            2
    j       after_processing_code
process_code_div:
    li      $s1,            13
    li      $s2,            2
    j       after_processing_code
process_code_mod:
    li      $s1,            14
    li      $s2,            2
    j       after_processing_code
process_code_eql:
    li      $s1,            15
    li      $s2,            3
    j       after_processing_code

after_processing_code:
    beq     $s2,            1,                          mode1
    beq     $s2,            2,                          mode2
    beq     $s2,            3,                          mode3

# Mode 1: Nếu toán tử cũ là "=", loại bỏ thông tin cũ. Cập nhật {toán hạng} mới, xuất ra số mới trên màn hình để ta thấy {toán hạng} mới.
mode1:
    beq     $s4,            15,                         mode1_1
    j       mode1_2
mode1_1:
    li      $s3,            0                                               # Reset
    li      $s4,            0                                               # Reset
    li      $s5,            0                                               # Reset
mode1_2:
    mul     $s3,            $s3,                        10
    add     $s3,            $s3,                        $s1
    add     $a0,            $zero,                      $s1                 # In ra số mới trên màn hình
    li      $v0,            1
    syscall 
    add     $a0,            $zero,                      $s3                 
    jal     display                                                         # In {toán hạng} SEVENSEG
    j       sleep

# Chế độ 2: Nếu {toán tử} cũ không thay đổi, không làm gì cả.
# Ngược lại, cập nhật {toán tử}, cập nhật {kết quả} = {toán hạng}, đầu ra {toán hạng} cũ, xóa {toán hạng} cũ.
mode2:
    beq     $s4,            $s1,                        sleep
    add     $s4,            $zero,                      $s1                 # cập nhật {toán tử}
    add     $s5,            $zero,                      $s3                 # cập nhật {kết quả} = {toán hạng}
    add     $a0,            $zero,                      $s3                 # đầu ra {toán hạng} cũ
    jal     display                                                         # In {toán hạng} SEVENSEG
    beq     $s1,            10,                         print_add
    beq     $s1,            11,                         print_sub
    beq     $s1,            12,                         print_mul
    beq     $s1,            13,                         print_div
    beq     $s1,            14,                         print_mod
mode2_2:           
    li      $s3,            0                                               # Xoá {toán hạng} cũ
    j       sleep
print_add:
    li      $a0,            '+'                                             # In toán tử tương ứng
    li      $v0,            11
    syscall
    j mode2_2

print_sub:
    li      $a0,            '-'                                             # In toán tử tương ứng
    li      $v0,            11
    syscall
    j mode2_2

print_mul:
    li      $a0,            '*'                                             # In toán tử tương ứng
    li      $v0,            11
    syscall
    j mode2_2

print_div:
    li      $a0,            '/'                                             # In toán tử tương ứng
    li      $v0,            11
    syscall
    j mode2_2

print_mod:
    li      $a0,            '%'                                             # In toán tử tương ứng
    li      $v0,            11
    syscall
    j mode2_2

# Chế độ 3: Cập nhật {kết quả} = {kết quả} {toán tử} {toán hạng}, cập nhật {toán tử}, cập nhật {toán hạng} = {kết quả}, đầu ra {kết quả} mới.
mode3:
    beq     $s4,            10,                         compu_add
    beq     $s4,            11,                         compu_sub
    beq     $s4,            12,                         compu_mul
    beq     $s4,            13,                         compu_div
    beq     $s4,            14,                         compu_mod
    beq     $s4,            15,                         compu_eql
compu_add:
    add     $s5,            $s5,                        $s3
    j       after_compu
compu_sub:
    sub     $s5,            $s5,                        $s3
    j       after_compu
compu_mul:
    mul     $s5,            $s5,                        $s3
    j       after_compu
compu_div:
    div     $s5,            $s3
    mflo    $s5
    j       after_compu
compu_mod:
    div     $s5,            $s3
    mfhi    $s5
    j       after_compu
compu_eql:
    j       after_compu
after_compu:
    li      $s4,            15                                              # Update {toán tử} = "="
    add     $s3,            $zero,                      $s5                 # Update {toán hạng} = {kết quả}
    li      $a0,            '='                                             # In dấu bằng
    li      $v0,            11
    syscall
    add     $a0,            $zero,                      $s5                 # Output {kết quả}
    li      $v0,            1
    syscall 
    jal     display                                                         # Output {kết quả} đến SEVENSEG
    j       sleep
sleep:
    li      $a0,            100                                            # Sleep 100ms
    li      $v0,            32
    syscall 
back_to_polling:
    j       polling                                                         # Continue polling


# hàm display:
# Tham số [in] $a0 số nguyên cần hiển thị".
display:
display_save:
    add     $sp,    $sp,    -24             # Mở rộng stack
    sw      $ra,    20($sp)                 # Lưu địa chỉ trả về
    sw      $s0,    16($sp)                 # Lưu giá trị thanh ghi $s0
    sw      $a0,    12($sp)             # Lưu giá trị tham số $a0 (số nguyên cần hiển thị)
    sw      $a1,    08($sp)             # Lưu giá trị tham số $a1 (địa chỉ của module 7 đoạn)
    sw      $t0,    04($sp)             # Lưu giá trị thanh ghi $t0
    sw      $t1,    00($sp)             # Lưu giá trị thanh ghi $t1
display_body:
    li      $t0,    10                  # Load 10 vào thanh ghi $t0
    add     $t1,    $zero,  $a0         # Sao chép giá trị tham số $a0 vào thanh ghi $t1
    div     $t1,    $t0                 # Chia $t1 cho 10
    mfhi    $a0                         # Lấy phần dư của phép chia, chứa hàng đơn vị
    li      $a1,    SEVENSEG_RIGHT      # Đặt địa chỉ của module 7 đoạn bên phải vào $a1
    jal     draw                        # Gọi hàm draw để hiển thị số hàng đơn vị
    mflo    $t1                         # Lấy phần thập phân của phép chia, chứa hàng chục
    div     $t1,    $t0                 # Chia phần thập phân cho 10
    mfhi    $a0                         # Lấy phần dư của phép chia, chứa hàng chục
    li      $a1,    SEVENSEG_LEFT       # Đặt địa chỉ của module 7 đoạn bên trái vào $a1
    jal     draw                        # Gọi hàm draw để hiển thị số hàng chục

display_load:
    lw      $t1,            00($sp)                                         # Load
    lw      $t0,            04($sp)                                         # Load
    lw      $a1,            08($sp)                                         # Load
    lw      $a0,            12($sp)                                         # Load
    lw      $s0,            16($sp)                                         # Load
    lw      $ra,            20($sp)                                         # Load
    add     $sp,            $sp,      +24                                   # Thu ngăn xếp
    jr      $ra

# Hàm vẽ:
# Tham số [in] $a0 số cần hiển thị
# Tham số [in] $a1 SEVENSEG để hiển thị

draw:
draw_save:
    add     $sp,    $sp,    -12         # Mở rộng stack
    sw      $ra,    08($sp)             # Lưu địa chỉ trả về
    sw      $t0,    04($sp)             # Lưu giá trị thanh ghi $t0
    sw      $t1,    00($sp)             # Lưu giá trị thanh ghi $t1

draw_body:
    la      $t0,    NUMS                # Load địa chỉ của mảng NUMS vào $t0
    sll     $t1,    $a0,    2           # Nhân $a0 (số cần hiển thị) với 4 (độ dịch trái 2 bit)
    add     $t0,    $t0,    $t1         # Tính địa chỉ của NUMS[$a0]
    lw      $t0,    0($t0)              # Load giá trị từ NUMS[$a0] vào $t0
    sb      $t0,    0($a1)              # Ghi giá trị này vào địa chỉ của module 7 đoạn ($a1)

draw_load:
    lw      $t1,    00($sp)             # Load giá trị thanh ghi $t1 từ stack
    lw      $t0,    04($sp)             # Load giá trị thanh ghi $t0 từ stack
    lw      $ra,    08($sp)             # Load địa chỉ trả về từ stack
    add     $sp,    $sp,    +12         # Thu hẹp stack
    jr      $ra                         # Trả về

