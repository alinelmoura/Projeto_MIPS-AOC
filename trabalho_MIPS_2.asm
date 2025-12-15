.data
    msg_titulo:     .asciiz "\n=============================================\n               Sistema de prevencao de enchentes  \n=============================================\n"
    msg_menu:       .asciiz "\n[1] Inserir nova leitura dos sensores\n[0] Sair\nEscolha: "
    msg_umidade:    .asciiz "\nDigite Umidade do Solo (0=Seco, 1=Umido): "
    msg_nivel:      .asciiz "\nDigite Nivel da Agua (0 a 10): "
    msg_media:      .asciiz "\nMedia Movel (ultimas 5 leituras): "
    msg_status:     .asciiz "\nStatus Atual: "
    msg_alarme:     .asciiz "\nAlarme Sonoro: "
    
    str_verde:      .asciiz "Livre de Risco - Sinal Verde"
    str_amarelo:    .asciiz "Alerta - Sinal Amarelo"
    str_vermelho:   .asciiz "Risco - Sinal Vermelho"
    str_on:         .asciiz "Ligado"
    str_off:        .asciiz "Desligado"
    
    historico:      .word 0, 0, 0, 0, 0
    indice_vetor:   .word 0
    tamanho_atual:  .word 0

.text
.globl main

main:
    li $v0, 4
    la $a0, msg_titulo
    syscall

loop_principal:
    li $v0, 4
    la $a0, msg_menu
    syscall
    
    li $v0, 5
    syscall
    move $t0, $v0
    
    beq $t0, $zero, sair_programa
    
    li $v0, 4
    la $a0, msg_umidade
    syscall
    li $v0, 5
    syscall
    move $s0, $v0
    
    li $v0, 4
    la $a0, msg_nivel
    syscall
    li $v0, 5
    syscall
    move $s1, $v0

    move $a0, $s1
    jal calcular_media
    move $s2, $v0

    move $a0, $s1
    move $a1, $s0
    jal verificar_status
    move $s3, $v0

    move $a0, $s2
    move $a1, $s3
    jal exibir_painel

    j loop_principal

sair_programa:
    li $v0, 10
    syscall

calcular_media:
    addi $sp, $sp, -16 
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t8, 12($sp)

    la $t0, tamanho_atual
    lw $t8, 0($t0)
    
    li $t9, 5
    bge $t8, $t9, vetor_cheio
    
    addi $t8, $t8, 1 
    sw $t8, 0($t0) 
    
vetor_cheio:
    la $t0, indice_vetor
    lw $t1, 0($t0)
    
    la $t2, historico
    mul $t3, $t1, 4    
    add $t3, $t3, $t2   
    sw $a0, 0($t3)
    
    addi $t1, $t1, 1
    div $t1, $t9      
    mfhi $t1
    sw $t1, 0($t0)
    
    li $t5, 0  
    li $t6, 0     
    la $t2, historico   
    
loop_soma:
bge $t6, $t8, fim_soma  
    
    lw $t7, 0($t2)
    add $t5, $t5, $t7    
    
    addi $t2, $t2, 4     
    addi $t6, $t6, 1    
    j loop_soma

fim_soma:
    div $t5, $t8
    mflo $v0  
    
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t8, 12($sp)
    addi $sp, $sp, 16
    jr $ra

verificar_status:
    ble $a0, 3, status_verde
    beq $a1, 1, status_vermelho
    bgt $a0, 6, status_vermelho
    j status_amarelo

status_verde:
    li $v0, 0
    jr $ra

status_amarelo:
    li $v0, 1
    jr $ra

status_vermelho:
    li $v0, 2
    jr $ra

exibir_painel:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a1, 4($sp)

    move $t0, $a0
    li $v0, 4
    la $a0, msg_media
    syscall
    
    li $v0, 1
    move $a0, $t0
    syscall

    li $v0, 4
    la $a0, msg_status
    syscall
    
    lw $a1, 4($sp)
    beq $a1, 0, print_vd
    beq $a1, 1, print_am
    beq $a1, 2, print_vm

print_vd:
    la $a0, str_verde
    syscall
    j check_alarme
print_am:
    la $a0, str_amarelo
    syscall
    j check_alarme
print_vm:
    la $a0, str_vermelho
    syscall

check_alarme:
    li $v0, 4
    la $a0, msg_alarme
    syscall

    lw $a1, 4($sp)
    beq $a1, 2, alarme_on
    
    la $a0, str_off
    syscall
    j fim_exibir

alarme_on:
    la $a0, str_on
    syscall

fim_exibir:
    li $v0, 11
    li $a0, 10
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra