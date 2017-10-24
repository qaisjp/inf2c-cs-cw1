#=========================================================================
# convert_pig_latin.s
#=========================================================================
# 
# Inf2C Computer Systems
#
# Qais Patankar - s1620208
#
# The comment structure for Data Segment / Text Segment and other functions have been
# borrowed from hex.s given in this coursework.

#==================================================================
# DATA SEGMENT
#==================================================================
.data
    #--------------------------------------------------------------


.text

li $v0, 1 # syscall print int
li $a0, 0 # print out 0
syscall

li $v0, 1 # syscall print int
move $a0, $zero # print out $zero
syscall

li $v0, 1 # syscall print int
move $a0, $0 # print out $0
syscall