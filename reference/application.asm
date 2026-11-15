; Application image - MC9S08AW16 Audi A6 C7 MFL steering-wheel module (LIN slave)
; Generated annotated disassembly (HCS08). Addresses are absolute.
; Symbol names are the reverse-engineering labels used in the C sources.


;---------------------------------------------------------------
; Flash_BurstProgram   [0xC400]   <- C913, C934, C950
;---------------------------------------------------------------
  C400:  a6aa         lda    #$AA
  C402:  c71800       sta    SRS
  C405:  b6a8         lda    $A8
  C407:  b7a2         sta    $A2
  C409:  b6a9         lda    $A9
  C40B:  b7a3         sta    $A3
  C40D:  a630         lda    #$30
  C40F:  c71825       sta    FSTAT
  C412:  6e40a5       mov    #$40, $A5
  C415:  95           tsx    
  C416:  35a6         sthx   $A6
  C418:  45c463       ldhx   #$C463
LC41B:
  C41B:  f6           lda    ,x
  C41C:  87           psha   
  C41D:  afff         aix    #$FF
  C41F:  3ba5f9       dbnz   $A5, LC41B
  C422:  95           tsx    
  C423:  fc           jmp    ,x
;   .... data/gap C424-C464 ....

;---------------------------------------------------------------
; Flash_ErasePage   [0xC464]   <- C8EF
;---------------------------------------------------------------
  C464:  074afd       brclr  3, ICGS1, Flash_ErasePage
  C467:  c61825       lda    FSTAT
  C46A:  aa10         ora    #$10
  C46C:  c71825       sta    FSTAT
  C46F:  a64c         lda    #$4C
  C471:  c71820       sta    FCDIV
  C474:  a655         lda    #$55
  C476:  c71800       sta    SRS
  C479:  b6a8         lda    $A8
  C47B:  b7a2         sta    $A2
  C47D:  b6a9         lda    $A9
  C47F:  b7a3         sta    $A3
  C481:  a630         lda    #$30
  C483:  c71825       sta    FSTAT
  C486:  6e24a5       mov    #$24, $A5
  C489:  95           tsx    
  C48A:  35a6         sthx   $A6
  C48C:  45c4bb       ldhx   #$C4BB
LC48F:
  C48F:  f6           lda    ,x
  C490:  87           psha   
  C491:  afff         aix    #$FF
  C493:  3ba5f9       dbnz   $A5, LC48F
  C496:  95           tsx    
  C497:  fc           jmp    ,x
;   .... data/gap C498-C4C0 ....

;---------------------------------------------------------------
; App_Startup   [0xC4C0]   <- C599
;---------------------------------------------------------------
  C4C0:  45046f       ldhx   #$046F
  C4C3:  94           txs    
  C4C4:  45fe80       ldhx   #$FE80
LC4C7:
  C4C7:  e601         lda    1,x
  C4C9:  87           psha   
  C4CA:  f6           lda    ,x
  C4CB:  87           psha   
LC4CC:
  C4CC:  e602         lda    2,x
  C4CE:  2749         beq    LC519
  C4D0:  a560         bit    #$60
  C4D2:  2606         bne    LC4DA
  C4D4:  a702         ais    #$02
  C4D6:  af05         aix    #$05
  C4D8:  20ed         bra    LC4C7
LC4DA:
  C4DA:  89           pshx   
  C4DB:  8b           pshh   
  C4DC:  e606         lda    6,x
  C4DE:  e001         sub    1,x
  C4E0:  87           psha   
  C4E1:  e605         lda    5,x
  C4E3:  f2           sbc    ,x
  C4E4:  9e6d01       tst    1,s
  C4E7:  2701         beq    LC4EA
  C4E9:  4c           inca   
LC4EA:
  C4EA:  87           psha   
  C4EB:  e603         lda    3,x
  C4ED:  87           psha   
  C4EE:  ee04         ldx    4,x
  C4F0:  8a           pulh   
LC4F1:
  C4F1:  89           pshx   
  C4F2:  8b           pshh   
  C4F3:  9eee07       ldx    7,s
  C4F6:  89           pshx   
  C4F7:  8a           pulh   
  C4F8:  9eee08       ldx    8,s
  C4FB:  9e6c08       inc    8,s
  C4FE:  2603         bne    LC503
  C500:  9e6c07       inc    7,s
LC503:
  C503:  f6           lda    ,x
  C504:  8a           pulh   
  C505:  88           pulx   
  C506:  f7           sta    ,x
  C507:  af01         aix    #$01
  C509:  9e6b02e4     dbnz   2,s, LC4F1
  C50D:  9e6b01e0     dbnz   1,s, LC4F1
  C511:  a702         ais    #$02
  C513:  8a           pulh   
  C514:  88           pulx   
  C515:  af05         aix    #$05
  C517:  20b3         bra    LC4CC
LC519:
  C519:  a702         ais    #$02
  C51B:  4501a0       ldhx   #$01A0
  C51E:  2003         bra    LC523
LC520:
  C520:  7f           clr    ,x
  C521:  af01         aix    #$01
LC523:
  C523:  6502c2       cphx   #$02C2
  C526:  26f8         bne    LC520
  C528:  cdc52d       jsr    main
LC52B:
  C52B:  20fe         bra    LC52B

;---------------------------------------------------------------
; main   [0xC52D]   <- C528
;---------------------------------------------------------------
  C52D:  ad1e         bsr    App_InitAll
  C52F:  4f           clra   
  C530:  c701a0       sta    g_tickCount
  C533:  c701a3       sta    g_tickSnapshot
  C536:  c701a2       sta    g_slot10
  C539:  c701a1       sta    g_tickFlag
  C53C:  c71808       sta    SRTISC
LC53F:
  C53F:  c601a1       lda    g_tickFlag
  C542:  4bfb         dbnza  LC53F
  C544:  cdc5fa       jsr    Scheduler_Run
  C547:  4f           clra   
  C548:  c701a1       sta    g_tickFlag
  C54B:  20f2         bra    LC53F

;---------------------------------------------------------------
; App_InitAll   [0xC54D]   <- main, C6C8
;---------------------------------------------------------------
  C54D:  cdf5e6       jsr    EnterCritical
  C550:  cdc6d0       jsr    Clock_Init
  C553:  cdc6ef       jsr    SysOpt_Init
  C556:  cdc739       jsr    COP_Feed
  C559:  cdf28e       jsr    Ports_Init
  C55C:  cdc7db       jsr    Nvm_Init
  C55F:  cdf690       jsr    Inputs_Init
  C562:  cdc7b6       jsr    Tpm2_Init
  C565:  cdc739       jsr    COP_Feed
  C568:  cdc792       jsr    Tpm1_Init
  C56B:  cdfa6b       jsr    $FA6B
  C56E:  cde78b       jsr    $E78B
  C571:  cde271       jsr    $E271
  C574:  cdf3f1       jsr    $F3F1
  C577:  cdea88       jsr    $EA88
  C57A:  cde7cf       jsr    $E7CF
  C57D:  cde229       jsr    Sensor_Init
  C580:  cdf73f       jsr    $F73F
  C583:  cde2fb       jsr    $E2FB
  C586:  cde517       jsr    $E517
  C589:  cdf607       jsr    $F607
  C58C:  cdcc56       jsr    $CC56
  C58F:  cdeabe       jsr    $EABE
  C592:  ccf5f3       jmp    ExitCritical

;---------------------------------------------------------------
; Isr_Default   [0xC595]
;---------------------------------------------------------------
  C595:  8b           pshh   
  C596:  b6ce         lda    g_scratch
  C598:  87           psha   
  C599:  cdc4c0       jsr    App_Startup
  C59C:  86           pula   
  C59D:  b7ce         sta    g_scratch
  C59F:  8a           pulh   
  C5A0:  80           rti    

;---------------------------------------------------------------
; sub_C5A1   [0xC5A1]   <- C6A7
;---------------------------------------------------------------
  C5A1:  c60100       lda    $0100
  C5A4:  a402         and    #$02
  C5A6:  2703         beq    LC5AB
  C5A8:  cdc6bd       jsr    Sleep_Enter
LC5AB:
  C5AB:  c6026b       lda    $026B
  C5AE:  a401         and    #$01
  C5B0:  2717         beq    LC5C9
  C5B2:  c60101       lda    $0101
  C5B5:  2612         bne    LC5C9
  C5B7:  a601         lda    #$01
  C5B9:  c70100       sta    $0100
  C5BC:  cdc841       jsr    $C841
  C5BF:  5f           clrx   
  C5C0:  4f           clra   
  C5C1:  cde7cb       jsr    $E7CB
  C5C4:  a601         lda    #$01
  C5C6:  c70101       sta    $0101
LC5C9:
  C5C9:  81           rts    

;---------------------------------------------------------------
; sub_C5CA   [0xC5CA]   <- C974
;---------------------------------------------------------------
  C5CA:  450102       ldhx   #$0102
  C5CD:  fa           ora    ,x
  C5CE:  f7           sta    ,x
  C5CF:  450100       ldhx   #$0100
  C5D2:  4b05         dbnza  LC5D9
  C5D4:  f6           lda    ,x
  C5D5:  aa02         ora    #$02
  C5D7:  2003         bra    LC5DC
LC5D9:
  C5D9:  f6           lda    ,x
  C5DA:  a4fd         and    #$FD
LC5DC:
  C5DC:  f7           sta    ,x
  C5DD:  81           rts    

;---------------------------------------------------------------
; sub_C5DE   [0xC5DE]   <- C727
;---------------------------------------------------------------
  C5DE:  87           psha   
  C5DF:  89           pshx   
  C5E0:  cdf5e6       jsr    EnterCritical
  C5E3:  95           tsx    
  C5E4:  e601         lda    1,x
  C5E6:  4501a0       ldhx   #$01A0
  C5E9:  fb           add    ,x
  C5EA:  f7           sta    ,x
  C5EB:  ae64         ldx    #$64
  C5ED:  8c           clrh   
  C5EE:  52           div    
  C5EF:  8b           pshh   
  C5F0:  86           pula   
  C5F1:  c701a0       sta    g_tickCount
  C5F4:  cdf5f3       jsr    ExitCritical
  C5F7:  a702         ais    #$02
  C5F9:  81           rts    

;---------------------------------------------------------------
; Scheduler_Run   [0xC5FA]   <- C544
;---------------------------------------------------------------
  C5FA:  c601a0       lda    g_tickCount
  C5FD:  c701a3       sta    g_tickSnapshot
  C600:  a501         bit    #$01
  C602:  2605         bne    LC609
  C604:  ad3e         bsr    Task_2Ticks
  C606:  c601a3       lda    g_tickSnapshot
LC609:
  C609:  3fce         clr    g_scratch
  C60B:  8c           clrh   
  C60C:  ae0a         ldx    #$0A
  C60E:  cdfcfc       jsr    u8_mod
  C611:  4d           tsta   
  C612:  2606         bne    LC61A
  C614:  3dce         tst    g_scratch
  C616:  2602         bne    LC61A
  C618:  ad30         bsr    Task_10Ticks
LC61A:
  C61A:  c601a3       lda    g_tickSnapshot
  C61D:  3fce         clr    g_scratch
  C61F:  8c           clrh   
  C620:  ae19         ldx    #$19
  C622:  cdfcfc       jsr    u8_mod
  C625:  4d           tsta   
  C626:  2607         bne    LC62F
  C628:  3dce         tst    g_scratch
  C62A:  2603         bne    LC62F
  C62C:  cdc6b7       jsr    Task_25Ticks
LC62F:
  C62F:  c601a3       lda    g_tickSnapshot
  C632:  a164         cmp    #$64
  C634:  250d         bcs    LC643
  C636:  cdf5e6       jsr    EnterCritical
  C639:  4f           clra   
  C63A:  c701a0       sta    g_tickCount
  C63D:  c701a3       sta    g_tickSnapshot
  C640:  cdf5f3       jsr    ExitCritical
LC643:
  C643:  81           rts    

;---------------------------------------------------------------
; Task_2Ticks   [0xC644]   <- C604
;---------------------------------------------------------------
  C644:  cdf80a       jsr    $F80A
  C647:  ccc739       jmp    COP_Feed

;---------------------------------------------------------------
; Task_10Ticks   [0xC64A]   <- C618
;---------------------------------------------------------------
  C64A:  4501a2       ldhx   #$01A2
  C64D:  7c           inc    ,x
  C64E:  cdc6f6       jsr    NvmTask_Run
  C651:  cdcd0a       jsr    $CD0A
  C654:  cde337       jsr    $E337
  C657:  cde7f8       jsr    $E7F8
  C65A:  c601a2       lda    g_slot10
  C65D:  4a           deca   
  C65E:  a10a         cmp    #$0A
  C660:  244e         bcc    LC6B0
  C662:  cdfd76       jsr    switch_jump
;   .... data/gap C665-C67B ....
LC67B:
  C67B:  cdcc7e       jsr    $CC7E
  C67E:  2034         bra    LC6B4
LC680:
  C680:  cde796       jsr    $E796
  C683:  cdfad4       jsr    $FAD4
  C686:  202c         bra    LC6B4
LC688:
  C688:  cdf628       jsr    $F628
  C68B:  cdcc7e       jsr    $CC7E
  C68E:  c60266       lda    $0266
  C691:  4b21         dbnza  LC6B4
  C693:  4f           clra   
  C694:  c70266       sta    $0266
  C697:  201b         bra    LC6B4
LC699:
  C699:  cdcc7e       jsr    $CC7E
  C69C:  cdf33b       jsr    $F33B
  C69F:  2013         bra    LC6B4
LC6A1:
  C6A1:  cdf628       jsr    $F628
  C6A4:  cdfad4       jsr    $FAD4
  C6A7:  cdc5a1       jsr    $C5A1
  C6AA:  cdccfc       jsr    $CCFC
  C6AD:  cdf3f8       jsr    $F3F8
LC6B0:
  C6B0:  4f           clra   
  C6B1:  c701a2       sta    g_slot10
LC6B4:
  C6B4:  ccc6f6       jmp    NvmTask_Run

;---------------------------------------------------------------
; Task_25Ticks   [0xC6B7]   <- C62C
;---------------------------------------------------------------
  C6B7:  cdccd3       jsr    $CCD3
  C6BA:  ccec3a       jmp    $EC3A

;---------------------------------------------------------------
; Sleep_Enter   [0xC6BD]   <- C5A8
;---------------------------------------------------------------
  C6BD:  9b           sei    
  C6BE:  cdcd10       jsr    $CD10
  C6C1:  cdf385       jsr    $F385
  C6C4:  cdf39b       jsr    $F39B
  C6C7:  8e           stop   
  C6C8:  cdc54d       jsr    App_InitAll
  C6CB:  4f           clra   
  C6CC:  c70100       sta    $0100
  C6CF:  81           rts    

;---------------------------------------------------------------
; Clock_Init   [0xC6D0]   <- C550
;---------------------------------------------------------------
  C6D0:  a62a         lda    #$2A
  C6D2:  c70048       sta    ICGC1
  C6D5:  a670         lda    #$70
  C6D7:  c70049       sta    ICGC2
LC6DA:
  C6DA:  c6004a       lda    ICGS1
  C6DD:  a408         and    #$08
  C6DF:  27f9         beq    LC6DA
LC6E1:
  C6E1:  c6004b       lda    ICGS2
  C6E4:  a501         bit    #$01
  C6E6:  27f9         beq    LC6E1
  C6E8:  c6ffbe       lda    $FFBE
  C6EB:  c7004e       sta    ICGTRM
  C6EE:  81           rts    

;---------------------------------------------------------------
; SysOpt_Init   [0xC6EF]   <- C553
;---------------------------------------------------------------
  C6EF:  a6ef         lda    #$EF
  C6F1:  c71802       sta    SOPT
  C6F4:  2043         bra    COP_Feed

;---------------------------------------------------------------
; NvmTask_Run   [0xC6F6]   <- C64E
;---------------------------------------------------------------
  C6F6:  87           psha   
  C6F7:  95           tsx    
  C6F8:  7f           clr    ,x
  C6F9:  ad3e         bsr    COP_Feed
  C6FB:  450103       ldhx   #$0103
  C6FE:  7c           inc    ,x
  C6FF:  f6           lda    ,x
  C700:  a106         cmp    #$06
  C702:  2530         bcs    LC734
  C704:  cdf375       jsr    $F375
  C707:  cdf5e6       jsr    EnterCritical
  C70A:  cdc8af       jsr    Nvm_Process
  C70D:  95           tsx    
  C70E:  f7           sta    ,x
  C70F:  271b         beq    LC72C
  C711:  ad26         bsr    COP_Feed
  C713:  cdf37d       jsr    $F37D
  C716:  95           tsx    
  C717:  f6           lda    ,x
  C718:  ae05         ldx    #$05
  C71A:  8c           clrh   
  C71B:  52           div    
  C71C:  c70103       sta    $0103
  C71F:  95           tsx    
  C720:  fe           ldx    ,x
  C721:  8c           clrh   
  C722:  af01         aix    #$01
  C724:  9f           txa    
  C725:  8b           pshh   
  C726:  88           pulx   
  C727:  cdc5de       jsr    $C5DE
  C72A:  2003         bra    LC72F
LC72C:
  C72C:  c70103       sta    $0103
LC72F:
  C72F:  cdf5f3       jsr    ExitCritical
  C732:  2003         bra    LC737
LC734:
  C734:  cdf37d       jsr    $F37D
LC737:
  C737:  8a           pulh   
  C738:  81           rts    

;---------------------------------------------------------------
; COP_Feed   [0xC739]   <- C556, C565, C6F9, C711
;---------------------------------------------------------------
  C739:  a655         lda    #$55
  C73B:  c71800       sta    SRS
  C73E:  48           lsla   
  C73F:  c71800       sta    SRS
  C742:  81           rts    

;---------------------------------------------------------------
; Isr_Tpm2Ch0   [0xC743]
;---------------------------------------------------------------
  C743:  8b           pshh   
  C744:  b6ce         lda    g_scratch
  C746:  87           psha   
  C747:  87           psha   
  C748:  c60065       lda    TPM2C0SC
  C74B:  95           tsx    
  C74C:  f7           sta    ,x
  C74D:  320066       ldhx   TPM2C0VH
  C750:  9601a4       sthx   $01A4
  C753:  450065       ldhx   #$0065
  C756:  f6           lda    ,x
  C757:  a47f         and    #$7F
  C759:  f7           sta    ,x
  C75A:  c601a5       lda    $01A5
  C75D:  ab0e         add    #$0E
  C75F:  c701a5       sta    $01A5
  C762:  c601a4       lda    $01A4
  C765:  a927         adc    #$27
  C767:  c701a4       sta    $01A4
  C76A:  c70066       sta    TPM2C0VH
  C76D:  c601a5       lda    $01A5
  C770:  c70067       sta    TPM2C0VL
  C773:  450104       ldhx   #$0104
  C776:  7c           inc    ,x
  C777:  f6           lda    ,x
  C778:  44           lsra   
  C779:  a101         cmp    #$01
  C77B:  260b         bne    LC788
  C77D:  c701a1       sta    g_tickFlag
  C780:  7f           clr    ,x
  C781:  cddd6c       jsr    LinTp_Timer
  C784:  4501a0       ldhx   #$01A0
  C787:  7c           inc    ,x
LC788:
  C788:  cde537       jsr    Scan_Isr
  C78B:  8a           pulh   
  C78C:  86           pula   
  C78D:  b7ce         sta    g_scratch
  C78F:  8a           pulh   
  C790:  80           rti    
;   .... data/gap C791-C792 ....

;---------------------------------------------------------------
; Tpm1_Init   [0xC792]   <- C568
;---------------------------------------------------------------
  C792:  a649         lda    #$49
  C794:  c70020       sta    TPM1SC
  C797:  a6c8         lda    #$C8
  C799:  c70023       sta    TPM1MODH
  C79C:  4f           clra   
  C79D:  c70024       sta    TPM1MODL
  C7A0:  a6c8         lda    #$C8
  C7A2:  c7002c       sta    TPM1C2VH
  C7A5:  4f           clra   
  C7A6:  c7002d       sta    TPM1C2VL
  C7A9:  c7002b       sta    TPM1C2SC
  C7AC:  c70025       sta    TPM1C0SC
  C7AF:  c70028       sta    TPM1C1SC
  C7B2:  c7002e       sta    TPM1C3SC
  C7B5:  81           rts    

;---------------------------------------------------------------
; Tpm2_Init   [0xC7B6]   <- C562
;---------------------------------------------------------------
  C7B6:  45270e       ldhx   #$270E
  C7B9:  9601a4       sthx   $01A4
  C7BC:  a608         lda    #$08
  C7BE:  c70060       sta    TPM2SC
  C7C1:  4f           clra   
  C7C2:  c70063       sta    TPM2MODH
  C7C5:  c70064       sta    TPM2MODL
  C7C8:  a650         lda    #$50
  C7CA:  c70065       sta    TPM2C0SC
  C7CD:  4f           clra   
  C7CE:  c70068       sta    TPM2C1SC
  C7D1:  960066       sthx   TPM2C0VH
  C7D4:  c70069       sta    TPM2C1VH
  C7D7:  c7006a       sta    TPM2C1VL
  C7DA:  81           rts    

;---------------------------------------------------------------
; Nvm_Init   [0xC7DB]   <- C55C
;---------------------------------------------------------------
  C7DB:  cec07f       ldx    $C07F
  C7DE:  4f           clra   
  C7DF:  cbc000       add    $C000
  C7E2:  2401         bcc    LC7E5
  C7E4:  5c           incx   
LC7E5:
  C7E5:  c701ab       sta    $01AB
  C7E8:  cf01aa       stx    $01AA
  C7EB:  cec27f       ldx    $C27F
  C7EE:  4f           clra   
  C7EF:  cbc200       add    $C200
  C7F2:  2401         bcc    LC7F5
  C7F4:  5c           incx   
LC7F5:
  C7F5:  c701a9       sta    $01A9
  C7F8:  cf01a8       stx    $01A8
  C7FB:  3201aa       ldhx   $01AA
  C7FE:  3e01a8       cphx   $01A8
  C801:  2409         bcc    LC80C
  C803:  651001       cphx   #$1001
  C806:  2404         bcc    LC80C
  C808:  a601         lda    #$01
  C80A:  2018         bra    LC824
LC80C:
  C80C:  3201a8       ldhx   $01A8
  C80F:  3e01aa       cphx   $01AA
  C812:  240e         bcc    LC822
  C814:  651001       cphx   #$1001
  C817:  2409         bcc    LC822
  C819:  a602         lda    #$02
  C81B:  c701a7       sta    $01A7
  C81E:  a6c2         lda    #$C2
  C820:  2007         bra    LC829
LC822:
  C822:  a603         lda    #$03
LC824:
  C824:  c701a7       sta    $01A7
  C827:  a6c0         lda    #$C0
LC829:
  C829:  c701ac       sta    $01AC
  C82C:  4f           clra   
  C82D:  c701ad       sta    $01AD
  C830:  c701ae       sta    $01AE
  C833:  cdc981       jsr    $C981
  C836:  4f           clra   
  C837:  c700aa       sta    $00AA
  C83A:  450120       ldhx   #$0120
  C83D:  9600a0       sthx   $00A0
  C840:  81           rts    

;---------------------------------------------------------------
; sub_C841   [0xC841]   <- C5BC
;---------------------------------------------------------------
  C841:  c6026a       lda    $026A
  C844:  4a           deca   
  C845:  2662         bne    LC8A9
  C847:  c601ae       lda    $01AE
  C84A:  265d         bne    LC8A9
  C84C:  a601         lda    #$01
  C84E:  c701ae       sta    $01AE
  C851:  c601a7       lda    $01A7
  C854:  a101         cmp    #$01
  C856:  261e         bne    LC876
  C858:  3201aa       ldhx   $01AA
  C85B:  650086       cphx   #$0086
  C85E:  2516         bcs    LC876
  C860:  afff         aix    #$FF
  C862:  9601aa       sthx   $01AA
  C865:  c601aa       lda    $01AA
  C868:  5f           clrx   
  C869:  c7019f       sta    $019F
  C86C:  c601ab       lda    $01AB
  C86F:  c70120       sta    $0120
  C872:  a6c2         lda    #$C2
  C874:  2020         bra    LC896
LC876:
  C876:  a102         cmp    #$02
  C878:  2624         bne    LC89E
  C87A:  3201a8       ldhx   $01A8
  C87D:  650086       cphx   #$0086
  C880:  251c         bcs    LC89E
  C882:  afff         aix    #$FF
  C884:  9601a8       sthx   $01A8
  C887:  c601a8       lda    $01A8
  C88A:  5f           clrx   
  C88B:  c7019f       sta    $019F
  C88E:  c601a9       lda    $01A9
  C891:  c70120       sta    $0120
  C894:  a6c0         lda    #$C0
LC896:
  C896:  c701ac       sta    $01AC
  C899:  4f           clra   
  C89A:  c701ad       sta    $01AD
  C89D:  81           rts    
LC89E:
  C89E:  4f           clra   
  C89F:  c701ae       sta    $01AE
  C8A2:  c7026a       sta    $026A
  C8A5:  5f           clrx   
  C8A6:  4c           inca   
  C8A7:  2003         bra    LC8AC
LC8A9:
  C8A9:  5f           clrx   
  C8AA:  a601         lda    #$01
LC8AC:
  C8AC:  ccc5ca       jmp    $C5CA

;---------------------------------------------------------------
; Nvm_Process   [0xC8AF]   <- C70A
;---------------------------------------------------------------
  C8AF:  a7fd         ais    #$FD
  C8B1:  95           tsx    
  C8B2:  6f02         clr    2,x
  C8B4:  c601ae       lda    $01AE
  C8B7:  2603         bne    LC8BC
  C8B9:  ccc97b       jmp    $C97B
LC8BC:
  C8BC:  410117       cbeqa  #$01, LC8D6
  C8BF:  41022a       cbeqa  #$02, LC8EC
  C8C2:  410339       cbeqa  #$03, LC8FE
  C8C5:  a104         cmp    #$04
  C8C7:  2603         bne    LC8CC
  C8C9:  ccc95f       jmp    $C95F
LC8CC:
  C8CC:  a105         cmp    #$05
  C8CE:  2603         bne    LC8D3
  C8D0:  ccc971       jmp    $C971
LC8D3:
  C8D3:  ccc977       jmp    $C977
LC8D6:
  C8D6:  4f           clra   
  C8D7:  c7026a       sta    $026A
  C8DA:  c601ac       lda    $01AC
  C8DD:  5f           clrx   
  C8DE:  c700a8       sta    $00A8
  C8E1:  c601ad       lda    $01AD
  C8E4:  c700a9       sta    $00A9
  C8E7:  a602         lda    #$02
  C8E9:  ccc978       jmp    $C978
LC8EC:
  C8EC:  cdf5e6       jsr    EnterCritical
  C8EF:  cdc464       jsr    Flash_ErasePage
  C8F2:  cdf5f3       jsr    ExitCritical
  C8F5:  a615         lda    #$15
  C8F7:  95           tsx    
  C8F8:  e702         sta    2,x
  C8FA:  a603         lda    #$03
  C8FC:  207a         bra    LC978
LC8FE:
  C8FE:  450120       ldhx   #$0120
  C901:  9eff01       sthx   1,s
  C904:  9600a0       sthx   $00A0
  C907:  a680         lda    #$80
  C909:  c700a4       sta    $00A4
  C90C:  cdf5e6       jsr    EnterCritical
  C90F:  4f           clra   
  C910:  c700aa       sta    $00AA
  C913:  cdc400       jsr    Flash_BurstProgram
  C916:  a601         lda    #$01
  C918:  c700aa       sta    $00AA
  C91B:  ce01ac       ldx    $01AC
  C91E:  4f           clra   
  C91F:  ab80         add    #$80
  C921:  2401         bcc    LC924
  C923:  5c           incx   
LC924:
  C924:  cf00a8       stx    $00A8
  C927:  c601ad       lda    $01AD
  C92A:  ab80         add    #$80
  C92C:  c700a9       sta    $00A9
  C92F:  a67f         lda    #$7F
  C931:  c700a4       sta    $00A4
  C934:  cdc400       jsr    Flash_BurstProgram
  C937:  a601         lda    #$01
  C939:  c700aa       sta    $00AA
  C93C:  c601ac       lda    $01AC
  C93F:  4c           inca   
  C940:  c700a8       sta    $00A8
  C943:  c601ad       lda    $01AD
  C946:  ab00         add    #$00
  C948:  c700a9       sta    $00A9
  C94B:  a6ff         lda    #$FF
  C94D:  c700a4       sta    $00A4
  C950:  cdc400       jsr    Flash_BurstProgram
  C953:  cdf5f3       jsr    ExitCritical
  C956:  a60b         lda    #$0B
  C958:  95           tsx    
  C959:  e702         sta    2,x
  C95B:  a604         lda    #$04
  C95D:  2019         bra    LC978
LC95F:
  C95F:  ad57         bsr    LC9B8
  C961:  95           tsx    
  C962:  e701         sta    1,x
  C964:  7f           clr    ,x
  C965:  9eae         ldhx   ,x
  C967:  2704         beq    LC96D
  C969:  a605         lda    #$05
  C96B:  200b         bra    LC978
LC96D:
  C96D:  a601         lda    #$01
  C96F:  2007         bra    LC978
LC971:
  C971:  5f           clrx   
  C972:  a601         lda    #$01
  C974:  cdc5ca       jsr    $C5CA
LC977:
  C977:  4f           clra   
LC978:
  C978:  c701ae       sta    $01AE
LC97B:
  C97B:  95           tsx    
  C97C:  e602         lda    2,x
  C97E:  a703         ais    #$03
  C980:  81           rts    

;---------------------------------------------------------------
; sub_C981   [0xC981]   <- C833
;---------------------------------------------------------------
  C981:  a7fd         ais    #$FD
  C983:  ad33         bsr    LC9B8
  C985:  95           tsx    
  C986:  f7           sta    ,x
  C987:  262c         bne    LC9B5
  C989:  c6026a       lda    $026A
  C98C:  2627         bne    LC9B5
  C98E:  c601ae       lda    $01AE
  C991:  2622         bne    LC9B5
  C993:  3201ac       ldhx   $01AC
  C996:  9eff02       sthx   2,s
  C999:  271a         beq    LC9B5
  C99B:  95           tsx    
  C99C:  f7           sta    ,x
LC99D:
  C99D:  eb02         add    2,x
  C99F:  87           psha   
  C9A0:  4f           clra   
  C9A1:  e901         adc    1,x
  C9A3:  87           psha   
  C9A4:  8a           pulh   
  C9A5:  88           pulx   
  C9A6:  f6           lda    ,x
  C9A7:  9eee01       ldx    1,s
  C9AA:  8c           clrh   
  C9AB:  d70120       sta    $0120,x
  C9AE:  95           tsx    
  C9AF:  7c           inc    ,x
  C9B0:  f6           lda    ,x
  C9B1:  a180         cmp    #$80
  C9B3:  25e8         bcs    LC99D
LC9B5:
  C9B5:  a703         ais    #$03
  C9B7:  81           rts    

;---------------------------------------------------------------
; sub_C9B8   [0xC9B8]   <- C95F, C983
;---------------------------------------------------------------
  C9B8:  a7fc         ais    #$FC
  C9BA:  3201ac       ldhx   $01AC
  C9BD:  9eff02       sthx   2,s
  C9C0:  a601         lda    #$01
  C9C2:  95           tsx    
  C9C3:  e703         sta    3,x
  C9C5:  9ece01       ldhx   1,x
  C9C8:  2722         beq    LC9EC
  C9CA:  4f           clra   
  C9CB:  95           tsx    
  C9CC:  f7           sta    ,x
LC9CD:
  C9CD:  eb02         add    2,x
  C9CF:  87           psha   
  C9D0:  4f           clra   
  C9D1:  e901         adc    1,x
  C9D3:  87           psha   
  C9D4:  8a           pulh   
  C9D5:  88           pulx   
  C9D6:  f6           lda    ,x
  C9D7:  9eee01       ldx    1,s
  C9DA:  8c           clrh   
  C9DB:  d10120       cmp    $0120,x
  C9DE:  2703         beq    LC9E3
  C9E0:  95           tsx    
  C9E1:  6f03         clr    3,x
LC9E3:
  C9E3:  95           tsx    
  C9E4:  7c           inc    ,x
  C9E5:  f6           lda    ,x
  C9E6:  a180         cmp    #$80
  C9E8:  25e3         bcs    LC9CD
  C9EA:  e603         lda    3,x
LC9EC:
  C9EC:  a704         ais    #$04
  C9EE:  81           rts    
;   .... data/gap C9EF-CA17 ....

;---------------------------------------------------------------
; sub_CA17   [0xCA17]   <- D10B
;---------------------------------------------------------------
  CA17:  87           psha   
  CA18:  89           pshx   
  CA19:  c60262       lda    $0262
  CA1C:  4b20         dbnza  LCA3E
  CA1E:  9efe01       ldhx   1,s
  CA21:  930b         ble    LCA2E
  CA23:  c6004e       lda    ICGTRM
  CA26:  2716         beq    LCA3E
  CA28:  45004e       ldhx   #$004E
  CA2B:  7a           dec    ,x
  CA2C:  2010         bra    LCA3E
LCA2E:
  CA2E:  65ffff       cphx   #$FFFF
  CA31:  900b         bge    LCA3E
  CA33:  c6004e       lda    ICGTRM
  CA36:  a1ff         cmp    #$FF
  CA38:  2404         bcc    LCA3E
  CA3A:  45004e       ldhx   #$004E
  CA3D:  7c           inc    ,x
LCA3E:
  CA3E:  a702         ais    #$02
  CA40:  81           rts    

;---------------------------------------------------------------
; LinErr_Set   [0xCA41]   <- D688, D6E1, D6F0, D72E, D94F, DE4F, DE7A, DED8
;---------------------------------------------------------------
  CA41:  45026b       ldhx   #$026B
  CA44:  f6           lda    ,x
  CA45:  aa04         ora    #$04
  CA47:  f7           sta    ,x
  CA48:  81           rts    
;   .... data/gap CA49-CA54 ....

;---------------------------------------------------------------
; sub_CA54   [0xCA54]   <- D748, D75B, D772, DD64
;---------------------------------------------------------------
  CA54:  87           psha   
  CA55:  89           pshx   
  CA56:  45026b       ldhx   #$026B
  CA59:  f6           lda    ,x
  CA5A:  aa04         ora    #$04
  CA5C:  f7           sta    ,x
  CA5D:  95           tsx    
  CA5E:  e601         lda    1,x
  CA60:  410305       cbeqa  #$03, LCA68
  CA63:  a650         lda    #$50
  CA65:  c702aa       sta    $02AA
LCA68:
  CA68:  a702         ais    #$02
  CA6A:  81           rts    

;---------------------------------------------------------------
; sub_CA6B   [0xCA6B]   <- DAD3
;---------------------------------------------------------------
  CA6B:  45026b       ldhx   #$026B
  CA6E:  f6           lda    ,x
  CA6F:  a4fe         and    #$FE
  CA71:  f7           sta    ,x
  CA72:  cccd1b       jmp    $CD1B

;---------------------------------------------------------------
; sub_CA75   [0xCA75]   <- DABA
;---------------------------------------------------------------
  CA75:  cdcd1b       jsr    $CD1B
  CA78:  c6026b       lda    $026B
  CA7B:  a404         and    #$04
  CA7D:  2607         bne    LCA86
  CA7F:  45026b       ldhx   #$026B
  CA82:  f6           lda    ,x
  CA83:  aa01         ora    #$01
  CA85:  f7           sta    ,x
LCA86:
  CA86:  81           rts    
LCA87:
  CA87:  a7fd         ais    #$FD
  CA89:  ce01ee       ldx    $01EE
  CA8C:  4f           clra   
  CA8D:  cb01ef       add    $01EF
  CA90:  2401         bcc    LCA93
  CA92:  5c           incx   
LCA93:
  CA93:  9ee703       sta    3,s
  CA96:  9eef02       stx    2,s
  CA99:  3201eb       ldhx   $01EB
  CA9C:  650002       cphx   #$0002
  CA9F:  2703         beq    LCAA4
  CAA1:  cccb38       jmp    $CB38
LCAA4:
  CAA4:  9eee02       ldx    2,s
  CAA7:  bfce         stx    g_scratch
  CAA9:  45fe9d       ldhx   #$FE9D
  CAAC:  ccfd89       jmp    $FD89
;   .... data/gap CAAF-CB38 ....
LCB38:
  CB38:  5f           clrx   
  CB39:  a613         lda    #$13
  CB3B:  cde083       jsr    $E083
  CB3E:  a703         ais    #$03
  CB40:  81           rts    

;---------------------------------------------------------------
; sub_CB41   [0xCB41]   <- DA12
;---------------------------------------------------------------
  CB41:  87           psha   
  CB42:  89           pshx   
  CB43:  a7fd         ais    #$FD
  CB45:  95           tsx    
  CB46:  6f02         clr    2,x
  CB48:  9ece03       ldhx   3,x
  CB4B:  2603         bne    LCB50
LCB4D:
  CB4D:  cccc50       jmp    $CC50
LCB50:
  CB50:  9efe08       ldhx   8,s
  CB53:  27f8         beq    LCB4D
  CB55:  9efe04       ldhx   4,s
  CB58:  f6           lda    ,x
  CB59:  41311d       cbeqa  #$31, LCB79
  CB5C:  413238       cbeqa  #$32, LCB97
  CB5F:  a133         cmp    #$33
  CB61:  276f         beq    LCBD2
  CB63:  a134         cmp    #$34
  CB65:  2603         bne    LCB6A
  CB67:  cccbf0       jmp    $CBF0
LCB6A:
  CB6A:  a135         cmp    #$35
  CB6C:  2603         bne    LCB71
  CB6E:  cccbfe       jmp    $CBFE
LCB71:
  CB71:  a601         lda    #$01
  CB73:  95           tsx    
  CB74:  e702         sta    2,x
  CB76:  cccc50       jmp    $CC50
LCB79:
  CB79:  e601         lda    1,x
  CB7B:  95           tsx    
  CB7C:  e701         sta    1,x
  CB7E:  7f           clr    ,x
  CB7F:  9ece03       ldhx   3,x
  CB82:  4f           clra   
  CB83:  9eeb02       add    2,s
  CB86:  9ee702       sta    2,s
  CB89:  e602         lda    2,x
  CB8B:  95           tsx    
  CB8C:  f9           adc    ,x
  CB8D:  f7           sta    ,x
  CB8E:  9eae         ldhx   ,x
  CB90:  f6           lda    ,x
  CB91:  9efe08       ldhx   8,s
  CB94:  cccc4c       jmp    $CC4C
LCB97:
  CB97:  e601         lda    1,x
  CB99:  95           tsx    
  CB9A:  e702         sta    2,x
  CB9C:  e701         sta    1,x
  CB9E:  7f           clr    ,x
  CB9F:  9ece03       ldhx   3,x
  CBA2:  4f           clra   
  CBA3:  9eeb02       add    2,s
  CBA6:  9ee702       sta    2,s
  CBA9:  e602         lda    2,x
  CBAB:  95           tsx    
  CBAC:  f9           adc    ,x
  CBAD:  f7           sta    ,x
  CBAE:  9eae         ldhx   ,x
  CBB0:  65c080       cphx   #$C080
  CBB3:  2417         bcc    LCBCC
  CBB5:  95           tsx    
  CBB6:  e602         lda    2,x
  CBB8:  a180         cmp    #$80
  CBBA:  2410         bcc    LCBCC
  CBBC:  9ece03       ldhx   3,x
  CBBF:  e603         lda    3,x
  CBC1:  9eee03       ldx    3,s
  CBC4:  8c           clrh   
  CBC5:  d70120       sta    $0120,x
  CBC8:  a601         lda    #$01
  CBCA:  2001         bra    LCBCD
LCBCC:
  CBCC:  4f           clra   
LCBCD:
  CBCD:  c7026a       sta    $026A
  CBD0:  207b         bra    LCC4D
LCBD2:
  CBD2:  320268       ldhx   $0268
  CBD5:  9eff01       sthx   1,s
  CBD8:  9f           txa    
  CBD9:  9efe08       ldhx   8,s
  CBDC:  f7           sta    ,x
  CBDD:  95           tsx    
  CBDE:  f6           lda    ,x
  CBDF:  9ece07       ldhx   7,x
  CBE2:  e701         sta    1,x
  CBE4:  c6019e       lda    $019E
  CBE7:  e702         sta    2,x
  CBE9:  c6019d       lda    $019D
  CBEC:  e703         sta    3,x
  CBEE:  205d         bra    LCC4D
LCBF0:
  CBF0:  c6019e       lda    $019E
  CBF3:  9efe08       ldhx   8,s
  CBF6:  f7           sta    ,x
  CBF7:  c6019d       lda    $019D
  CBFA:  e701         sta    1,x
  CBFC:  204f         bra    LCC4D
LCBFE:
  CBFE:  e601         lda    1,x
  CC00:  a47f         and    #$7F
  CC02:  95           tsx    
  CC03:  e701         sta    1,x
  CC05:  7f           clr    ,x
  CC06:  97           tax    
  CC07:  8c           clrh   
  CC08:  d60120       lda    $0120,x
  CC0B:  9efe08       ldhx   8,s
  CC0E:  f7           sta    ,x
  CC0F:  95           tsx    
  CC10:  e601         lda    1,x
  CC12:  4c           inca   
  CC13:  a47f         and    #$7F
  CC15:  8c           clrh   
  CC16:  97           tax    
  CC17:  d60120       lda    $0120,x
  CC1A:  9efe08       ldhx   8,s
  CC1D:  af01         aix    #$01
  CC1F:  9eff08       sthx   8,s
  CC22:  f7           sta    ,x
  CC23:  95           tsx    
  CC24:  e601         lda    1,x
  CC26:  ab02         add    #$02
  CC28:  a47f         and    #$7F
  CC2A:  8c           clrh   
  CC2B:  97           tax    
  CC2C:  d60120       lda    $0120,x
  CC2F:  9efe08       ldhx   8,s
  CC32:  af01         aix    #$01
  CC34:  9eff08       sthx   8,s
  CC37:  f7           sta    ,x
  CC38:  95           tsx    
  CC39:  e601         lda    1,x
  CC3B:  ab03         add    #$03
  CC3D:  a47f         and    #$7F
  CC3F:  8c           clrh   
  CC40:  97           tax    
  CC41:  d60120       lda    $0120,x
  CC44:  9efe08       ldhx   8,s
  CC47:  af01         aix    #$01
  CC49:  9eff08       sthx   8,s
LCC4C:
  CC4C:  f7           sta    ,x
LCC4D:
  CC4D:  95           tsx    
  CC4E:  6f02         clr    2,x
LCC50:
  CC50:  95           tsx    
  CC51:  e602         lda    2,x
  CC53:  a705         ais    #$05
  CC55:  81           rts    

;---------------------------------------------------------------
; sub_CC56   [0xCC56]   <- C58C
;---------------------------------------------------------------
  CC56:  87           psha   
  CC57:  4f           clra   
  CC58:  c701b7       sta    $01B7
  CC5B:  cdf5e6       jsr    EnterCritical
  CC5E:  cdcd1b       jsr    $CD1B
  CC61:  cdd65a       jsr    $D65A
  CC64:  cdd17b       jsr    $D17B
  CC67:  cde02c       jsr    $E02C
  CC6A:  45026b       ldhx   #$026B
  CC6D:  f6           lda    ,x
  CC6E:  a4fb         and    #$FB
  CC70:  f7           sta    ,x
  CC71:  5f           clrx   
  CC72:  a602         lda    #$02
  CC74:  cdd6d2       jsr    $D6D2
  CC77:  95           tsx    
  CC78:  f7           sta    ,x
  CC79:  cdf5f3       jsr    ExitCritical
  CC7C:  8a           pulh   
  CC7D:  81           rts    

;---------------------------------------------------------------
; sub_CC7E   [0xCC7E]   <- C67B, C68B, C699
;---------------------------------------------------------------
  CC7E:  c6026b       lda    $026B
  CC81:  a504         bit    #$04
  CC83:  2648         bne    LCCCD
  CC85:  c601c7       lda    $01C7
  CC88:  a47f         and    #$7F
  CC8A:  c702aa       sta    $02AA
  CC8D:  c601bd       lda    $01BD
  CC90:  62           nsa    
  CC91:  a40f         and    #$0F
  CC93:  c702af       sta    $02AF
  CC96:  c601bd       lda    $01BD
  CC99:  a40f         and    #$0F
  CC9B:  c702ae       sta    $02AE
  CC9E:  c601be       lda    $01BE
  CCA1:  a40f         and    #$0F
  CCA3:  c702b0       sta    $02B0
  CCA6:  c601be       lda    $01BE
  CCA9:  62           nsa    
  CCAA:  a404         and    #$04
  CCAC:  44           lsra   
  CCAD:  44           lsra   
  CCAE:  c702b3       sta    $02B3
  CCB1:  c601be       lda    $01BE
  CCB4:  62           nsa    
  CCB5:  a402         and    #$02
  CCB7:  44           lsra   
  CCB8:  c702b2       sta    $02B2
  CCBB:  c601c8       lda    $01C8
  CCBE:  a401         and    #$01
  CCC0:  c702ab       sta    $02AB
  CCC3:  c601be       lda    $01BE
  CCC6:  62           nsa    
  CCC7:  a401         and    #$01
  CCC9:  c702b1       sta    $02B1
  CCCC:  81           rts    
LCCCD:
  CCCD:  a650         lda    #$50
  CCCF:  c702aa       sta    $02AA
  CCD2:  81           rts    

;---------------------------------------------------------------
; sub_CCD3   [0xCCD3]   <- Task_25Ticks
;---------------------------------------------------------------
  CCD3:  cdd722       jsr    $D722
  CCD6:  c601b6       lda    $01B6
  CCD9:  a1ff         cmp    #$FF
  CCDB:  2404         bcc    LCCE1
  CCDD:  4501b6       ldhx   #$01B6
  CCE0:  7c           inc    ,x
LCCE1:
  CCE1:  ce0191       ldx    $0191
  CCE4:  4f           clra   
  CCE5:  cb0192       add    $0192
  CCE8:  2401         bcc    LCCEB
  CCEA:  5c           incx   
LCCEB:
  CCEB:  c001b4       sub    $01B4
  CCEE:  9f           txa    
  CCEF:  c201b3       sbc    $01B3
  CCF2:  2407         bcc    LCCFB
  CCF4:  45026b       ldhx   #$026B
  CCF7:  f6           lda    ,x
  CCF8:  aa01         ora    #$01
  CCFA:  f7           sta    ,x
LCCFB:
  CCFB:  81           rts    

;---------------------------------------------------------------
; sub_CCFC   [0xCCFC]   <- C6AA
;---------------------------------------------------------------
  CCFC:  3201b3       ldhx   $01B3
  CCFF:  65ffff       cphx   #$FFFF
  CD02:  2405         bcc    LCD09
  CD04:  af01         aix    #$01
  CD06:  9601b3       sthx   $01B3
LCD09:
  CD09:  81           rts    

;---------------------------------------------------------------
; sub_CD0A   [0xCD0A]   <- C651
;---------------------------------------------------------------
  CD0A:  cde037       jsr    $E037
  CD0D:  ccd191       jmp    $D191

;---------------------------------------------------------------
; sub_CD10   [0xCD10]   <- C6BE
;---------------------------------------------------------------
  CD10:  4f           clra   
  CD11:  c7003b       sta    SCI1C2
  CD14:  81           rts    

;---------------------------------------------------------------
; sub_CD15   [0xCD15]   <- D941
;---------------------------------------------------------------
  CD15:  a606         lda    #$06
  CD17:  81           rts    

;---------------------------------------------------------------
; sub_CD18   [0xCD18]   <- D8FF, D9A1
;---------------------------------------------------------------
  CD18:  a606         lda    #$06
  CD1A:  81           rts    

;---------------------------------------------------------------
; sub_CD1B   [0xCD1B]   <- CA75, CC5E
;---------------------------------------------------------------
  CD1B:  c6019c       lda    $019C
  CD1E:  62           nsa    
  CD1F:  a40f         and    #$0F
  CD21:  c701b2       sta    $01B2
  CD24:  c6019c       lda    $019C
  CD27:  a40f         and    #$0F
  CD29:  c701b0       sta    $01B0
  CD2C:  c6019b       lda    $019B
  CD2F:  a40f         and    #$0F
  CD31:  c701b1       sta    $01B1
  CD34:  a6f0         lda    #$F0
  CD36:  c701c0       sta    $01C0
  CD39:  4f           clra   
  CD3A:  c701c1       sta    $01C1
  CD3D:  c601c2       lda    $01C2
  CD40:  a4f0         and    #$F0
  CD42:  c701c2       sta    $01C2
  CD45:  c601c6       lda    $01C6
  CD48:  a4bf         and    #$BF
  CD4A:  c701c6       sta    $01C6
  CD4D:  c601bf       lda    $01BF
  CD50:  a4e0         and    #$E0
  CD52:  c701bf       sta    $01BF
  CD55:  c601b0       lda    $01B0
  CD58:  62           nsa    
  CD59:  c801c3       eor    $01C3
  CD5C:  a4f0         and    #$F0
  CD5E:  c801c3       eor    $01C3
  CD61:  c701c3       sta    $01C3
  CD64:  c801b2       eor    $01B2
  CD67:  a40f         and    #$0F
  CD69:  c801c3       eor    $01C3
  CD6C:  c701c3       sta    $01C3
  CD6F:  c6019c       lda    $019C
  CD72:  a406         and    #$06
  CD74:  410210       cbeqa  #$02, LCD87
  CD77:  c6019c       lda    $019C
  CD7A:  a406         and    #$06
  CD7C:  410608       cbeqa  #$06, LCD87
  CD7F:  a6ff         lda    #$FF
  CD81:  c701c9       sta    $01C9
  CD84:  4f           clra   
  CD85:  2004         bra    LCD8B
LCD87:
  CD87:  4f           clra   
  CD88:  c70297       sta    $0297
LCD8B:
  CD8B:  c701b5       sta    $01B5
  CD8E:  c701b6       sta    $01B6
  CD91:  c701b3       sta    $01B3
  CD94:  c701b4       sta    $01B4
  CD97:  4c           inca   
  CD98:  c701af       sta    $01AF
  CD9B:  13c6         bclr   1, $C6
  CD9D:  81           rts    
;   .... data/gap CD9E-CF10 ....

;---------------------------------------------------------------
; Sci_Init   [0xCF10]   <- D6CC
;---------------------------------------------------------------
  CF10:  87           psha   
  CF11:  3f38         clr    SCI1BDH
  CF13:  6e4139       mov    #$41, SCI1BDL
  CF16:  3f3a         clr    SCI1C1
  CF18:  6e0e3e       mov    #$0E, SCI1C3
  CF1B:  b63c         lda    SCI1S1
  CF1D:  9ee701       sta    1,s
  CF20:  b63f         lda    SCI1D
  CF22:  9ee701       sta    1,s
  CF25:  6e043d       mov    #$04, SCI1S2
  CF28:  6e2c3b       mov    #$2C, SCI1C2
  CF2B:  3fb0         clr    $B0
  CF2D:  4f           clra   
  CF2E:  c701bc       sta    $01BC
  CF31:  6e0868       mov    #$08, TPM2C1SC
  CF34:  8a           pulh   
  CF35:  81           rts    

;---------------------------------------------------------------
; Sci_SendByte   [0xCF36]   <- DE0B, DE56, DF23, DF3C
;---------------------------------------------------------------
  CF36:  87           psha   
  CF37:  89           pshx   
  CF38:  87           psha   
  CF39:  b63c         lda    SCI1S1
  CF3B:  9ee701       sta    1,s
  CF3E:  95           tsx    
  CF3F:  e602         lda    2,x
  CF41:  b73f         sta    SCI1D
  CF43:  a703         ais    #$03
  CF45:  81           rts    

;---------------------------------------------------------------
; Isr_Sci1   [0xCF46]
;---------------------------------------------------------------
  CF46:  8b           pshh   
  CF47:  b6ce         lda    g_scratch
  CF49:  87           psha   
  CF4A:  55cc         ldhx   $CC
  CF4C:  89           pshx   
  CF4D:  8b           pshh   
  CF4E:  55ca         ldhx   $CA
  CF50:  89           pshx   
  CF51:  8b           pshh   
  CF52:  a7fe         ais    #$FE
  CF54:  b63c         lda    SCI1S1
  CF56:  9ee701       sta    1,s
  CF59:  b63f         lda    SCI1D
  CF5B:  9ee702       sta    2,s
  CF5E:  9ee601       lda    1,s
  CF61:  a50e         bit    #$0E
  CF63:  2610         bne    LCF75
  CF65:  9ee601       lda    1,s
  CF68:  a520         bit    #$20
  CF6A:  2727         beq    LCF93
  CF6C:  9ee602       lda    2,s
  CF6F:  5f           clrx   
  CF70:  cddea6       jsr    Lin_RxByte
  CF73:  201e         bra    LCF93
LCF75:
  CF75:  9ee601       lda    1,s
  CF78:  a502         bit    #$02
  CF7A:  2705         beq    LCF81
  CF7C:  5f           clrx   
  CF7D:  a602         lda    #$02
  CF7F:  200f         bra    LCF90
LCF81:
  CF81:  9ee601       lda    1,s
  CF84:  a508         bit    #$08
  CF86:  2705         beq    LCF8D
  CF88:  5f           clrx   
  CF89:  a603         lda    #$03
  CF8B:  2003         bra    LCF90
LCF8D:
  CF8D:  5f           clrx   
  CF8E:  a604         lda    #$04
LCF90:
  CF90:  cddfb6       jsr    Lin_TxByteOrErr
LCF93:
  CF93:  a702         ais    #$02
  CF95:  8a           pulh   
  CF96:  88           pulx   
  CF97:  35ca         sthx   $CA
  CF99:  8a           pulh   
  CF9A:  88           pulx   
  CF9B:  35cc         sthx   $CC
  CF9D:  86           pula   
  CF9E:  b7ce         sta    g_scratch
  CFA0:  8a           pulh   
  CFA1:  80           rti    

;---------------------------------------------------------------
; sub_CFA2   [0xCFA2]
;---------------------------------------------------------------
  CFA2:  8b           pshh   
  CFA3:  b6ce         lda    g_scratch
  CFA5:  87           psha   
  CFA6:  55cc         ldhx   $CC
  CFA8:  89           pshx   
  CFA9:  8b           pshh   
  CFAA:  55ca         ldhx   $CA
  CFAC:  89           pshx   
  CFAD:  8b           pshh   
  CFAE:  a7fb         ais    #$FB
  CFB0:  b668         lda    TPM2C1SC
  CFB2:  c601bc       lda    $01BC
  CFB5:  a101         cmp    #$01
  CFB7:  2612         bne    LCFCB
  CFB9:  6e4468       mov    #$44, TPM2C1SC
  CFBC:  be69         ldx    TPM2C1VH
  CFBE:  b66a         lda    TPM2C1VL
  CFC0:  c701bb       sta    $01BB
  CFC3:  cf01ba       stx    $01BA
  CFC6:  a602         lda    #$02
  CFC8:  ccd114       jmp    $D114
LCFCB:
  CFCB:  a102         cmp    #$02
  CFCD:  264b         bne    LD01A
  CFCF:  be69         ldx    TPM2C1VH
  CFD1:  b66a         lda    TPM2C1VL
  CFD3:  9ee702       sta    2,s
  CFD6:  9eef01       stx    1,s
  CFD9:  6e4868       mov    #$48, TPM2C1SC
  CFDC:  9efe01       ldhx   1,s
  CFDF:  3e01ba       cphx   $01BA
  CFE2:  2418         bcc    LCFFC
  CFE4:  a6ff         lda    #$FF
  CFE6:  c001bb       sub    $01BB
  CFE9:  87           psha   
  CFEA:  a6ff         lda    #$FF
  CFEC:  c201ba       sbc    $01BA
  CFEF:  97           tax    
  CFF0:  86           pula   
  CFF1:  9eeb02       add    2,s
  CFF4:  9ee704       sta    4,s
  CFF7:  9f           txa    
  CFF8:  95           tsx    
  CFF9:  f9           adc    ,x
  CFFA:  200a         bra    LD006
LCFFC:
  CFFC:  c001bb       sub    $01BB
  CFFF:  95           tsx    
  D000:  e703         sta    3,x
  D002:  f6           lda    ,x
  D003:  c201ba       sbc    $01BA
LD006:
  D006:  e702         sta    2,x
  D008:  9ece02       ldhx   2,x
  D00B:  652cc3       cphx   #$2CC3
  D00E:  2505         bcs    LD015
  D010:  a603         lda    #$03
  D012:  ccd114       jmp    $D114
LD015:
  D015:  a601         lda    #$01
  D017:  ccd114       jmp    $D114
LD01A:
  D01A:  a103         cmp    #$03
  D01C:  2612         bne    LD030
  D01E:  6e4868       mov    #$48, TPM2C1SC
  D021:  be69         ldx    TPM2C1VH
  D023:  b66a         lda    TPM2C1VL
  D025:  c701bb       sta    $01BB
  D028:  cf01ba       stx    $01BA
  D02B:  a604         lda    #$04
  D02D:  ccd114       jmp    $D114
LD030:
  D030:  a104         cmp    #$04
  D032:  264a         bne    LD07E
  D034:  be69         ldx    TPM2C1VH
  D036:  b66a         lda    TPM2C1VL
  D038:  9ee702       sta    2,s
  D03B:  9eef01       stx    1,s
  D03E:  9efe01       ldhx   1,s
  D041:  3e01ba       cphx   $01BA
  D044:  2418         bcc    LD05E
  D046:  a6ff         lda    #$FF
  D048:  c001bb       sub    $01BB
  D04B:  87           psha   
  D04C:  a6ff         lda    #$FF
  D04E:  c201ba       sbc    $01BA
  D051:  97           tax    
  D052:  86           pula   
  D053:  9eeb02       add    2,s
  D056:  9ee704       sta    4,s
  D059:  9f           txa    
  D05A:  95           tsx    
  D05B:  f9           adc    ,x
  D05C:  200a         bra    LD068
LD05E:
  D05E:  c001bb       sub    $01BB
  D061:  95           tsx    
  D062:  e703         sta    3,x
  D064:  f6           lda    ,x
  D065:  c201ba       sbc    $01BA
LD068:
  D068:  e702         sta    2,x
  D06A:  6e4868       mov    #$48, TPM2C1SC
  D06D:  9ece02       ldhx   2,x
  D070:  9601b8       sthx   $01B8
  D073:  9efe01       ldhx   1,s
  D076:  9601ba       sthx   $01BA
  D079:  a605         lda    #$05
  D07B:  ccd114       jmp    $D114
LD07E:
  D07E:  a105         cmp    #$05
  D080:  2703         beq    LD085
  D082:  ccd110       jmp    $D110
LD085:
  D085:  be69         ldx    TPM2C1VH
  D087:  b66a         lda    TPM2C1VL
  D089:  9ee702       sta    2,s
  D08C:  9eef01       stx    1,s
  D08F:  9efe01       ldhx   1,s
  D092:  3e01ba       cphx   $01BA
  D095:  2418         bcc    LD0AF
  D097:  a6ff         lda    #$FF
  D099:  c001bb       sub    $01BB
  D09C:  87           psha   
  D09D:  a6ff         lda    #$FF
  D09F:  c201ba       sbc    $01BA
  D0A2:  97           tax    
  D0A3:  86           pula   
  D0A4:  9eeb02       add    2,s
  D0A7:  9ee704       sta    4,s
  D0AA:  9f           txa    
  D0AB:  95           tsx    
  D0AC:  f9           adc    ,x
  D0AD:  200a         bra    LD0B9
LD0AF:
  D0AF:  c001bb       sub    $01BB
  D0B2:  95           tsx    
  D0B3:  e703         sta    3,x
  D0B5:  f6           lda    ,x
  D0B6:  c201ba       sbc    $01BA
LD0B9:
  D0B9:  e702         sta    2,x
  D0BB:  3201b8       ldhx   $01B8
  D0BE:  affe         aix    #$FE
  D0C0:  9ef303       cphx   3,s
  D0C3:  224b         bhi    LD110
  D0C5:  3201b8       ldhx   $01B8
  D0C8:  af02         aix    #$02
  D0CA:  9ef303       cphx   3,s
  D0CD:  2541         bcs    LD110
  D0CF:  c601b9       lda    $01B9
  D0D2:  95           tsx    
  D0D3:  eb03         add    3,x
  D0D5:  87           psha   
  D0D6:  c601b8       lda    $01B8
  D0D9:  e902         adc    2,x
  D0DB:  97           tax    
  D0DC:  86           pula   
  D0DD:  ab20         add    #$20
  D0DF:  2401         bcc    LD0E2
  D0E1:  5c           incx   
LD0E2:
  D0E2:  c701b9       sta    $01B9
  D0E5:  cf01b8       stx    $01B8
  D0E8:  6e0868       mov    #$08, TPM2C1SC
  D0EB:  a606         lda    #$06
  D0ED:  4501b8       ldhx   #$01B8
LD0F0:
  D0F0:  74           lsr    ,x
  D0F1:  6601         ror    1,x
  D0F3:  4bfb         dbnza  LD0F0
  D0F5:  c601b8       lda    $01B8
  D0F8:  b738         sta    SCI1BDH
  D0FA:  c601b9       lda    $01B9
  D0FD:  b739         sta    SCI1BDL
  D0FF:  a624         lda    #$24
  D101:  95           tsx    
  D102:  e003         sub    3,x
  D104:  87           psha   
  D105:  a608         lda    #$08
  D107:  e202         sbc    2,x
  D109:  97           tax    
  D10A:  86           pula   
  D10B:  cdca17       jsr    $CA17
  D10E:  2003         bra    LD113
LD110:
  D110:  6e0868       mov    #$08, TPM2C1SC
LD113:
  D113:  4f           clra   
LD114:
  D114:  c701bc       sta    $01BC
  D117:  a705         ais    #$05
  D119:  8a           pulh   
  D11A:  88           pulx   
  D11B:  35ca         sthx   $CA
  D11D:  8a           pulh   
  D11E:  88           pulx   
  D11F:  35cc         sthx   $CC
  D121:  86           pula   
  D122:  b7ce         sta    g_scratch
  D124:  8a           pulh   
  D125:  80           rti    
LD126:
  D126:  87           psha   
  D127:  b668         lda    TPM2C1SC
  D129:  9ee701       sta    1,s
  D12C:  6e4868       mov    #$48, TPM2C1SC
  D12F:  a601         lda    #$01
  D131:  c701bc       sta    $01BC
  D134:  8a           pulh   
  D135:  81           rts    

;---------------------------------------------------------------
; sub_D136   [0xD136]   <- D191, D1C9, D6D5, D722, LinTp_Timer
;---------------------------------------------------------------
  D136:  87           psha   
  D137:  3cb0         inc    $B0
  D139:  95           tsx    
  D13A:  9f           txa    
  D13B:  8b           pshh   
  D13C:  88           pulx   
  D13D:  ad2f         bsr    LD16E
  D13F:  1b3b         bclr   5, SCI1C2
  D141:  b63e         lda    SCI1C3
  D143:  a4f1         and    #$F1
  D145:  b73e         sta    SCI1C3
  D147:  95           tsx    
  D148:  f6           lda    ,x
  D149:  5f           clrx   
  D14A:  ad29         bsr    LD175
  D14C:  8a           pulh   
  D14D:  81           rts    

;---------------------------------------------------------------
; sub_D14E   [0xD14E]   <- D1F3, D71A
;---------------------------------------------------------------
  D14E:  87           psha   
  D14F:  3db0         tst    $B0
  D151:  2702         beq    LD155
  D153:  3ab0         dec    $B0
LD155:
  D155:  3db0         tst    $B0
  D157:  2613         bne    LD16C
  D159:  95           tsx    
  D15A:  9f           txa    
  D15B:  8b           pshh   
  D15C:  88           pulx   
  D15D:  ad0f         bsr    LD16E
  D15F:  1a3b         bset   5, SCI1C2
  D161:  b63e         lda    SCI1C3
  D163:  aa0e         ora    #$0E
  D165:  b73e         sta    SCI1C3
  D167:  95           tsx    
  D168:  f6           lda    ,x
  D169:  5f           clrx   
  D16A:  ad09         bsr    LD175
LD16C:
  D16C:  8a           pulh   
  D16D:  81           rts    

;---------------------------------------------------------------
; sub_D16E   [0xD16E]   <- D13D, D15D
;---------------------------------------------------------------
  D16E:  89           pshx   
  D16F:  8a           pulh   
  D170:  97           tax    
  D171:  85           tpa    
  D172:  9b           sei    
  D173:  f7           sta    ,x
  D174:  81           rts    

;---------------------------------------------------------------
; sub_D175   [0xD175]   <- D14A, D16A
;---------------------------------------------------------------
  D175:  a408         and    #$08
  D177:  2601         bne    LD17A
  D179:  84           tap    
LD17A:
  D17A:  81           rts    

;---------------------------------------------------------------
; sub_D17B   [0xD17B]   <- CC64
;---------------------------------------------------------------
  D17B:  2000         bra    LD17D
LD17D:
  D17D:  4f           clra   
  D17E:  c701d5       sta    $01D5
  D181:  c701d4       sta    $01D4
  D184:  c701d0       sta    $01D0
  D187:  c701d1       sta    $01D1
  D18A:  c701cb       sta    $01CB
  D18D:  c701cc       sta    $01CC
  D190:  81           rts    
LD191:
  D191:  cdd136       jsr    $D136
  D194:  3201cb       ldhx   $01CB
  D197:  272a         beq    LD1C3
  D199:  afff         aix    #$FF
  D19B:  9601cb       sthx   $01CB
  D19E:  2623         bne    LD1C3
  D1A0:  c601d5       lda    $01D5
  D1A3:  270d         beq    LD1B2
  D1A5:  4f           clra   
  D1A6:  c701d5       sta    $01D5
  D1A9:  c701d4       sta    $01D4
  D1AC:  4c           inca   
  D1AD:  cde114       jsr    $E114
  D1B0:  2011         bra    LD1C3
LD1B2:
  D1B2:  c601d4       lda    $01D4
  D1B5:  270c         beq    LD1C3
  D1B7:  4f           clra   
  D1B8:  c701d5       sta    $01D5
  D1BB:  c701d4       sta    $01D4
  D1BE:  5f           clrx   
  D1BF:  4c           inca   
  D1C0:  cde0ec       jsr    $E0EC
LD1C3:
  D1C3:  ccd14e       jmp    $D14E
LD1C6:
  D1C6:  87           psha   
  D1C7:  89           pshx   
  D1C8:  87           psha   
  D1C9:  cdd136       jsr    $D136
  D1CC:  c601d5       lda    $01D5
  D1CF:  261e         bne    LD1EF
  D1D1:  a603         lda    #$03
  D1D3:  c701d5       sta    $01D5
  D1D6:  a664         lda    #$64
  D1D8:  c701cc       sta    $01CC
  D1DB:  4f           clra   
  D1DC:  c701cb       sta    $01CB
  D1DF:  9efe02       ldhx   2,s
  D1E2:  9601cd       sthx   $01CD
  D1E5:  c601e9       lda    $01E9
  D1E8:  c701d2       sta    $01D2
  D1EB:  95           tsx    
  D1EC:  7f           clr    ,x
  D1ED:  2004         bra    LD1F3
LD1EF:
  D1EF:  a601         lda    #$01
  D1F1:  95           tsx    
  D1F2:  f7           sta    ,x
LD1F3:
  D1F3:  cdd14e       jsr    $D14E
  D1F6:  95           tsx    
  D1F7:  f6           lda    ,x
  D1F8:  a703         ais    #$03
  D1FA:  81           rts    

;---------------------------------------------------------------
; sub_D1FB   [0xD1FB]   <- DB87
;---------------------------------------------------------------
  D1FB:  87           psha   
  D1FC:  c601d5       lda    $01D5
  D1FF:  410304       cbeqa  #$03, LD206
  D202:  a106         cmp    #$06
  D204:  2604         bne    LD20A
LD206:
  D206:  a601         lda    #$01
LD208:
  D208:  8a           pulh   
  D209:  81           rts    
LD20A:
  D20A:  4f           clra   
  D20B:  20fb         bra    LD208

;---------------------------------------------------------------
; sub_D20D   [0xD20D]   <- DC42
;---------------------------------------------------------------
  D20D:  87           psha   
  D20E:  89           pshx   
  D20F:  a7fd         ais    #$FD
  D211:  89           pshx   
  D212:  8a           pulh   
  D213:  97           tax    
  D214:  f6           lda    ,x
  D215:  a180         cmp    #$80
  D217:  2503         bcs    LD21C
  D219:  ccd445       jmp    $D445
LD21C:
  D21C:  9efe04       ldhx   4,s
  D21F:  f6           lda    ,x
  D220:  c101e9       cmp    $01E9
  D223:  2707         beq    LD22C
  D225:  a17f         cmp    #$7F
  D227:  2703         beq    LD22C
LD229:
  D229:  ccd43f       jmp    $D43F
LD22C:
  D22C:  e601         lda    1,x
  D22E:  a4f0         and    #$F0
  D230:  2718         beq    LD24A
  D232:  a110         cmp    #$10
  D234:  2603         bne    LD239
  D236:  ccd2c9       jmp    $D2C9
LD239:
  D239:  a120         cmp    #$20
  D23B:  2603         bne    LD240
  D23D:  ccd376       jmp    $D376
LD240:
  D240:  c601d4       lda    $01D4
  D243:  a101         cmp    #$01
  D245:  26e2         bne    LD229
  D247:  ccd441       jmp    $D441
LD24A:
  D24A:  e601         lda    1,x
  D24C:  27db         beq    LD229
  D24E:  a107         cmp    #$07
  D250:  24d7         bcc    LD229
  D252:  c601d4       lda    $01D4
  D255:  4b13         dbnza  LD26A
  D257:  4f           clra   
  D258:  c701cb       sta    $01CB
  D25B:  c701cc       sta    $01CC
  D25E:  5f           clrx   
  D25F:  4c           inca   
  D260:  cde0ec       jsr    $E0EC
  D263:  4f           clra   
  D264:  c701d5       sta    $01D5
  D267:  c701d4       sta    $01D4
LD26A:
  D26A:  c601d5       lda    $01D5
  D26D:  2713         beq    LD282
  D26F:  4f           clra   
  D270:  c701cb       sta    $01CB
  D273:  c701cc       sta    $01CC
  D276:  5f           clrx   
  D277:  4c           inca   
  D278:  cde114       jsr    $E114
  D27B:  4f           clra   
  D27C:  c701d5       sta    $01D5
  D27F:  c701d4       sta    $01D4
LD282:
  D282:  c601d4       lda    $01D4
  D285:  26a2         bne    LD229
  D287:  9efe04       ldhx   4,s
  D28A:  e601         lda    1,x
  D28C:  a40f         and    #$0F
  D28E:  5f           clrx   
  D28F:  87           psha   
  D290:  89           pshx   
  D291:  9efe06       ldhx   6,s
  D294:  f6           lda    ,x
  D295:  5f           clrx   
  D296:  cde0ae       jsr    $E0AE
  D299:  a702         ais    #$02
  D29B:  c701d3       sta    $01D3
  D29E:  410104       cbeqa  #$01, LD2A5
  D2A1:  a102         cmp    #$02
  D2A3:  2684         bne    LD229
LD2A5:
  D2A5:  a606         lda    #$06
  D2A7:  87           psha   
  D2A8:  4f           clra   
  D2A9:  87           psha   
  D2AA:  95           tsx    
  D2AB:  e606         lda    6,x
  D2AD:  ee05         ldx    5,x
  D2AF:  ab02         add    #$02
  D2B1:  2401         bcc    LD2B4
  D2B3:  5c           incx   
LD2B4:
  D2B4:  87           psha   
  D2B5:  89           pshx   
  D2B6:  a6ed         lda    #$ED
  D2B8:  ae01         ldx    #$01
  D2BA:  cde188       jsr    $E188
  D2BD:  a704         ais    #$04
  D2BF:  5f           clrx   
  D2C0:  4f           clra   
  D2C1:  cde0ec       jsr    $E0EC
  D2C4:  a602         lda    #$02
  D2C6:  ccd441       jmp    $D441
LD2C9:
  D2C9:  e601         lda    1,x
  D2CB:  a40f         and    #$0F
  D2CD:  9ee702       sta    2,s
  D2D0:  e602         lda    2,x
  D2D2:  95           tsx    
  D2D3:  e702         sta    2,x
  D2D5:  9ece01       ldhx   1,x
  D2D8:  650007       cphx   #$0007
  D2DB:  2403         bcc    LD2E0
LD2DD:
  D2DD:  ccd43f       jmp    $D43F
LD2E0:
  D2E0:  4f           clra   
  D2E1:  c701cb       sta    $01CB
  D2E4:  c701cc       sta    $01CC
  D2E7:  c601d4       lda    $01D4
  D2EA:  4b0c         dbnza  LD2F8
  D2EC:  4f           clra   
  D2ED:  c701d5       sta    $01D5
  D2F0:  c701d4       sta    $01D4
  D2F3:  5f           clrx   
  D2F4:  4c           inca   
  D2F5:  cde0ec       jsr    $E0EC
LD2F8:
  D2F8:  c601d5       lda    $01D5
  D2FB:  2713         beq    LD310
  D2FD:  4f           clra   
  D2FE:  c701cb       sta    $01CB
  D301:  c701cc       sta    $01CC
  D304:  5f           clrx   
  D305:  4c           inca   
  D306:  cde114       jsr    $E114
  D309:  4f           clra   
  D30A:  c701d5       sta    $01D5
  D30D:  c701d4       sta    $01D4
LD310:
  D310:  c601d4       lda    $01D4
  D313:  26c8         bne    LD2DD
  D315:  95           tsx    
  D316:  e602         lda    2,x
  D318:  87           psha   
  D319:  e601         lda    1,x
  D31B:  87           psha   
  D31C:  9ece03       ldhx   3,x
  D31F:  f6           lda    ,x
  D320:  5f           clrx   
  D321:  cde0ae       jsr    $E0AE
  D324:  a702         ais    #$02
  D326:  c701d3       sta    $01D3
  D329:  410104       cbeqa  #$01, LD330
  D32C:  a102         cmp    #$02
  D32E:  26ad         bne    LD2DD
LD330:
  D330:  a605         lda    #$05
  D332:  87           psha   
  D333:  4f           clra   
  D334:  87           psha   
  D335:  95           tsx    
  D336:  e606         lda    6,x
  D338:  ee05         ldx    5,x
  D33A:  ab03         add    #$03
  D33C:  2401         bcc    LD33F
  D33E:  5c           incx   
LD33F:
  D33F:  87           psha   
  D340:  89           pshx   
  D341:  a6ed         lda    #$ED
  D343:  ae01         ldx    #$01
  D345:  cde188       jsr    $E188
  D348:  a704         ais    #$04
  D34A:  a60a         lda    #$0A
  D34C:  c701cc       sta    $01CC
  D34F:  4f           clra   
  D350:  c701cb       sta    $01CB
  D353:  9efe02       ldhx   2,s
  D356:  affb         aix    #$FB
  D358:  9601cd       sthx   $01CD
  D35B:  a605         lda    #$05
  D35D:  c701d1       sta    $01D1
  D360:  4f           clra   
  D361:  c701d0       sta    $01D0
  D364:  9efe04       ldhx   4,s
  D367:  f6           lda    ,x
  D368:  c701d2       sta    $01D2
  D36B:  a601         lda    #$01
  D36D:  c701cf       sta    $01CF
  D370:  c701d4       sta    $01D4
  D373:  ccd441       jmp    $D441
LD376:
  D376:  c601d4       lda    $01D4
  D379:  4a           deca   
  D37A:  2703         beq    LD37F
LD37C:
  D37C:  ccd43f       jmp    $D43F
LD37F:
  D37F:  f6           lda    ,x
  D380:  c101d2       cmp    $01D2
  D383:  26f7         bne    LD37C
  D385:  e601         lda    1,x
  D387:  a40f         and    #$0F
  D389:  c101cf       cmp    $01CF
  D38C:  2703         beq    LD391
  D38E:  ccd42c       jmp    $D42C
LD391:
  D391:  3201cd       ldhx   $01CD
  D394:  650007       cphx   #$0007
  D397:  c601d3       lda    $01D3
  D39A:  2446         bcc    LD3E2
  D39C:  4b26         dbnza  LD3C4
  D39E:  c601ce       lda    $01CE
  D3A1:  87           psha   
  D3A2:  c601cd       lda    $01CD
  D3A5:  87           psha   
  D3A6:  95           tsx    
  D3A7:  e606         lda    6,x
  D3A9:  ee05         ldx    5,x
  D3AB:  ab02         add    #$02
  D3AD:  2401         bcc    LD3B0
  D3AF:  5c           incx   
LD3B0:
  D3B0:  87           psha   
  D3B1:  89           pshx   
  D3B2:  c601d1       lda    $01D1
  D3B5:  abed         add    #$ED
  D3B7:  87           psha   
  D3B8:  c601d0       lda    $01D0
  D3BB:  a901         adc    #$01
  D3BD:  97           tax    
  D3BE:  86           pula   
  D3BF:  cde188       jsr    $E188
  D3C2:  a704         ais    #$04
LD3C4:
  D3C4:  4f           clra   
  D3C5:  c701cd       sta    $01CD
  D3C8:  c701ce       sta    $01CE
  D3CB:  c701cb       sta    $01CB
  D3CE:  c701cc       sta    $01CC
  D3D1:  a602         lda    #$02
  D3D3:  95           tsx    
  D3D4:  f7           sta    ,x
  D3D5:  4f           clra   
  D3D6:  c701d5       sta    $01D5
  D3D9:  c701d4       sta    $01D4
  D3DC:  5f           clrx   
  D3DD:  cde0ec       jsr    $E0EC
  D3E0:  2065         bra    LD447
LD3E2:
  D3E2:  4b23         dbnza  LD407
  D3E4:  a606         lda    #$06
  D3E6:  87           psha   
  D3E7:  4f           clra   
  D3E8:  87           psha   
  D3E9:  95           tsx    
  D3EA:  e606         lda    6,x
  D3EC:  ee05         ldx    5,x
  D3EE:  ab02         add    #$02
  D3F0:  2401         bcc    LD3F3
  D3F2:  5c           incx   
LD3F3:
  D3F3:  87           psha   
  D3F4:  89           pshx   
  D3F5:  c601d1       lda    $01D1
  D3F8:  abed         add    #$ED
  D3FA:  87           psha   
  D3FB:  c601d0       lda    $01D0
  D3FE:  a901         adc    #$01
  D400:  97           tax    
  D401:  86           pula   
  D402:  cde188       jsr    $E188
  D405:  a704         ais    #$04
LD407:
  D407:  3201d0       ldhx   $01D0
  D40A:  af06         aix    #$06
  D40C:  9601d0       sthx   $01D0
  D40F:  c601cf       lda    $01CF
  D412:  4c           inca   
  D413:  a40f         and    #$0F
  D415:  c701cf       sta    $01CF
  D418:  3201cd       ldhx   $01CD
  D41B:  affa         aix    #$FA
  D41D:  9601cd       sthx   $01CD
  D420:  a60a         lda    #$0A
  D422:  c701cc       sta    $01CC
  D425:  4f           clra   
  D426:  c701cb       sta    $01CB
  D429:  4c           inca   
  D42A:  2015         bra    LD441
LD42C:
  D42C:  4f           clra   
  D42D:  c701cb       sta    $01CB
  D430:  c701cc       sta    $01CC
  D433:  5f           clrx   
  D434:  4c           inca   
  D435:  cde0ec       jsr    $E0EC
  D438:  4f           clra   
  D439:  c701d5       sta    $01D5
  D43C:  c701d4       sta    $01D4
LD43F:
  D43F:  a603         lda    #$03
LD441:
  D441:  95           tsx    
  D442:  f7           sta    ,x
  D443:  2002         bra    LD447
LD445:
  D445:  95           tsx    
  D446:  7f           clr    ,x
LD447:
  D447:  95           tsx    
  D448:  f6           lda    ,x
  D449:  a705         ais    #$05
  D44B:  81           rts    

;---------------------------------------------------------------
; sub_D44C   [0xD44C]   <- DB92
;---------------------------------------------------------------
  D44C:  87           psha   
  D44D:  89           pshx   
  D44E:  c601d5       lda    $01D5
  D451:  a103         cmp    #$03
  D453:  2703         beq    LD458
  D455:  ccd505       jmp    $D505
LD458:
  D458:  4f           clra   
  D459:  c701cb       sta    $01CB
  D45C:  c701cc       sta    $01CC
  D45F:  c601d2       lda    $01D2
  D462:  9efe01       ldhx   1,s
  D465:  f7           sta    ,x
  D466:  3201cd       ldhx   $01CD
  D469:  650007       cphx   #$0007
  D46C:  2451         bcc    LD4BF
  D46E:  c601ce       lda    $01CE
  D471:  9efe01       ldhx   1,s
  D474:  e701         sta    1,x
  D476:  87           psha   
  D477:  c601cd       lda    $01CD
  D47A:  87           psha   
  D47B:  4501ed       ldhx   #$01ED
  D47E:  89           pshx   
  D47F:  8b           pshh   
  D480:  9efe05       ldhx   5,s
  D483:  af02         aix    #$02
  D485:  9f           txa    
  D486:  8b           pshh   
  D487:  88           pulx   
  D488:  cde188       jsr    $E188
  D48B:  a704         ais    #$04
  D48D:  a606         lda    #$06
  D48F:  c001ce       sub    $01CE
  D492:  87           psha   
  D493:  4f           clra   
  D494:  c201cd       sbc    $01CD
  D497:  87           psha   
  D498:  a6ff         lda    #$FF
  D49A:  87           psha   
  D49B:  4f           clra   
  D49C:  87           psha   
  D49D:  c601ce       lda    $01CE
  D4A0:  ab02         add    #$02
  D4A2:  95           tsx    
  D4A3:  eb05         add    5,x
  D4A5:  87           psha   
  D4A6:  4f           clra   
  D4A7:  e904         adc    4,x
  D4A9:  97           tax    
  D4AA:  86           pula   
  D4AB:  cde13a       jsr    $E13A
  D4AE:  a704         ais    #$04
  D4B0:  a604         lda    #$04
  D4B2:  c701d5       sta    $01D5
  D4B5:  4f           clra   
  D4B6:  c701cd       sta    $01CD
  D4B9:  c701ce       sta    $01CE
  D4BC:  ccd5bb       jmp    $D5BB
LD4BF:
  D4BF:  c601cd       lda    $01CD
  D4C2:  a40f         and    #$0F
  D4C4:  aa10         ora    #$10
  D4C6:  9efe01       ldhx   1,s
  D4C9:  e701         sta    1,x
  D4CB:  c601ce       lda    $01CE
  D4CE:  e702         sta    2,x
  D4D0:  a605         lda    #$05
  D4D2:  87           psha   
  D4D3:  4f           clra   
  D4D4:  87           psha   
  D4D5:  4501ed       ldhx   #$01ED
  D4D8:  89           pshx   
  D4D9:  8b           pshh   
  D4DA:  9efe05       ldhx   5,s
  D4DD:  af03         aix    #$03
  D4DF:  9f           txa    
  D4E0:  8b           pshh   
  D4E1:  88           pulx   
  D4E2:  cde188       jsr    $E188
  D4E5:  a704         ais    #$04
  D4E7:  3201cd       ldhx   $01CD
  D4EA:  affb         aix    #$FB
  D4EC:  9601cd       sthx   $01CD
  D4EF:  a601         lda    #$01
  D4F1:  c701cf       sta    $01CF
  D4F4:  a605         lda    #$05
  D4F6:  c701d1       sta    $01D1
  D4F9:  4f           clra   
  D4FA:  c701d0       sta    $01D0
  D4FD:  a605         lda    #$05
  D4FF:  c701d5       sta    $01D5
  D502:  ccd5bb       jmp    $D5BB
LD505:
  D505:  a106         cmp    #$06
  D507:  2703         beq    LD50C
  D509:  ccd5c4       jmp    $D5C4
LD50C:
  D50C:  4f           clra   
  D50D:  c701cb       sta    $01CB
  D510:  c701cc       sta    $01CC
  D513:  c601d2       lda    $01D2
  D516:  9efe01       ldhx   1,s
  D519:  f7           sta    ,x
  D51A:  c601cf       lda    $01CF
  D51D:  aa20         ora    #$20
  D51F:  e701         sta    1,x
  D521:  3201cd       ldhx   $01CD
  D524:  650007       cphx   #$0007
  D527:  2456         bcc    LD57F
  D529:  c601ce       lda    $01CE
  D52C:  87           psha   
  D52D:  c601cd       lda    $01CD
  D530:  87           psha   
  D531:  c601d1       lda    $01D1
  D534:  abed         add    #$ED
  D536:  87           psha   
  D537:  c601d0       lda    $01D0
  D53A:  a901         adc    #$01
  D53C:  87           psha   
  D53D:  9efe05       ldhx   5,s
  D540:  af02         aix    #$02
  D542:  9f           txa    
  D543:  8b           pshh   
  D544:  88           pulx   
  D545:  cde188       jsr    $E188
  D548:  a704         ais    #$04
  D54A:  a606         lda    #$06
  D54C:  c001ce       sub    $01CE
  D54F:  5f           clrx   
  D550:  87           psha   
  D551:  89           pshx   
  D552:  a6ff         lda    #$FF
  D554:  87           psha   
  D555:  4f           clra   
  D556:  87           psha   
  D557:  c601ce       lda    $01CE
  D55A:  ab02         add    #$02
  D55C:  9eeb06       add    6,s
  D55F:  87           psha   
  D560:  9f           txa    
  D561:  95           tsx    
  D562:  e905         adc    5,x
  D564:  97           tax    
  D565:  86           pula   
  D566:  cde13a       jsr    $E13A
  D569:  a704         ais    #$04
  D56B:  4f           clra   
  D56C:  c701d0       sta    $01D0
  D56F:  c701d1       sta    $01D1
  D572:  c701cd       sta    $01CD
  D575:  c701ce       sta    $01CE
  D578:  a607         lda    #$07
  D57A:  c701d5       sta    $01D5
  D57D:  203c         bra    LD5BB
LD57F:
  D57F:  a606         lda    #$06
  D581:  87           psha   
  D582:  4f           clra   
  D583:  87           psha   
  D584:  c601d1       lda    $01D1
  D587:  abed         add    #$ED
  D589:  87           psha   
  D58A:  c601d0       lda    $01D0
  D58D:  a901         adc    #$01
  D58F:  87           psha   
  D590:  9efe05       ldhx   5,s
  D593:  af02         aix    #$02
  D595:  9f           txa    
  D596:  8b           pshh   
  D597:  88           pulx   
  D598:  cde188       jsr    $E188
  D59B:  a704         ais    #$04
  D59D:  3201d0       ldhx   $01D0
  D5A0:  af06         aix    #$06
  D5A2:  9601d0       sthx   $01D0
  D5A5:  3201cd       ldhx   $01CD
  D5A8:  affa         aix    #$FA
  D5AA:  9601cd       sthx   $01CD
  D5AD:  a607         lda    #$07
  D5AF:  c701d5       sta    $01D5
  D5B2:  c601cf       lda    $01CF
  D5B5:  4c           inca   
  D5B6:  a40f         and    #$0F
  D5B8:  c701cf       sta    $01CF
LD5BB:
  D5BB:  a614         lda    #$14
  D5BD:  c701cc       sta    $01CC
  D5C0:  4f           clra   
  D5C1:  c701cb       sta    $01CB
LD5C4:
  D5C4:  a702         ais    #$02
  D5C6:  81           rts    

;---------------------------------------------------------------
; sub_D5C7   [0xD5C7]   <- DCBE
;---------------------------------------------------------------
  D5C7:  87           psha   
  D5C8:  c601d5       lda    $01D5
  D5CB:  a104         cmp    #$04
  D5CD:  2618         bne    LD5E7
  D5CF:  4f           clra   
  D5D0:  c701d5       sta    $01D5
  D5D3:  c701cb       sta    $01CB
  D5D6:  c701cc       sta    $01CC
  D5D9:  5f           clrx   
  D5DA:  cde114       jsr    $E114
  D5DD:  95           tsx    
  D5DE:  f7           sta    ,x
  D5DF:  2738         beq    LD619
  D5E1:  a101         cmp    #$01
  D5E3:  2636         bne    LD61B
  D5E5:  2034         bra    LD61B
LD5E7:
  D5E7:  a105         cmp    #$05
  D5E9:  2709         beq    LD5F4
  D5EB:  a107         cmp    #$07
  D5ED:  262a         bne    LD619
  D5EF:  3201cd       ldhx   $01CD
  D5F2:  2711         beq    LD605
LD5F4:
  D5F4:  a606         lda    #$06
  D5F6:  c701d5       sta    $01D5
  D5F9:  a632         lda    #$32
  D5FB:  c701cc       sta    $01CC
  D5FE:  4f           clra   
  D5FF:  c701cb       sta    $01CB
  D602:  4c           inca   
  D603:  2016         bra    LD61B
LD605:
  D605:  4f           clra   
  D606:  c701d5       sta    $01D5
  D609:  c701cb       sta    $01CB
  D60C:  c701cc       sta    $01CC
  D60F:  cde114       jsr    $E114
  D612:  95           tsx    
  D613:  f7           sta    ,x
  D614:  2703         beq    LD619
  D616:  410102       cbeqa  #$01, LD61B
LD619:
  D619:  a603         lda    #$03
LD61B:
  D61B:  8a           pulh   
  D61C:  81           rts    

;---------------------------------------------------------------
; sub_D61D   [0xD61D]   <- DC39, DD00, DD17
;---------------------------------------------------------------
  D61D:  c601d5       lda    $01D5
  D620:  410407       cbeqa  #$04, LD62A
  D623:  410504       cbeqa  #$05, LD62A
  D626:  a107         cmp    #$07
  D628:  2613         bne    LD63D
LD62A:
  D62A:  4f           clra   
  D62B:  c701d5       sta    $01D5
  D62E:  c701d4       sta    $01D4
  D631:  c701cb       sta    $01CB
  D634:  c701cc       sta    $01CC
  D637:  5f           clrx   
  D638:  4c           inca   
  D639:  cde114       jsr    $E114
LD63C:
  D63C:  81           rts    
LD63D:
  D63D:  c601d4       lda    $01D4
  D640:  4bfa         dbnza  LD63C
  D642:  4f           clra   
  D643:  c701d5       sta    $01D5
  D646:  c701d4       sta    $01D4
  D649:  c701cd       sta    $01CD
  D64C:  c701ce       sta    $01CE
  D64F:  c701d0       sta    $01D0
  D652:  c701d1       sta    $01D1
  D655:  5f           clrx   
  D656:  4c           inca   
  D657:  cce0ec       jmp    $E0EC

;---------------------------------------------------------------
; sub_D65A   [0xD65A]   <- CC61
;---------------------------------------------------------------
  D65A:  a653         lda    #$53
  D65C:  c701e4       sta    $01E4
  D65F:  a601         lda    #$01
  D661:  87           psha   
  D662:  4f           clra   
  D663:  87           psha   
  D664:  a6c6         lda    #$C6
  D666:  ae00         ldx    #$00
  D668:  cde15c       jsr    $E15C
  D66B:  a702         ais    #$02
  D66D:  a601         lda    #$01
  D66F:  87           psha   
  D670:  4f           clra   
  D671:  87           psha   
  D672:  a6c8         lda    #$C8
  D674:  ae00         ldx    #$00
  D676:  cde15c       jsr    $E15C
  D679:  a702         ais    #$02
  D67B:  ad02         bsr    LD67F
  D67D:  4f           clra   
  D67E:  81           rts    

;---------------------------------------------------------------
; sub_D67F   [0xD67F]   <- D67B
;---------------------------------------------------------------
  D67F:  c601e4       lda    $01E4
  D682:  415306       cbeqa  #$53, LD68B
  D685:  5f           clrx   
  D686:  a621         lda    #$21
  D688:  cdca41       jsr    LinErr_Set
LD68B:
  D68B:  3fc5         clr    $C5
  D68D:  3fc3         clr    $C3
  D68F:  3fc2         clr    $C2
  D691:  3fc1         clr    $C1
  D693:  a602         lda    #$02
  D695:  c701d9       sta    $01D9
  D698:  6e02b8       mov    #$02, $B8
  D69B:  a60a         lda    #$0A
  D69D:  c701e9       sta    $01E9
  D6A0:  4f           clra   
  D6A1:  c701e2       sta    $01E2
  D6A4:  a604         lda    #$04
  D6A6:  87           psha   
  D6A7:  4f           clra   
  D6A8:  87           psha   
  D6A9:  45fecd       ldhx   #$FECD
  D6AC:  89           pshx   
  D6AD:  8b           pshh   
  D6AE:  a6e5         lda    #$E5
  D6B0:  ae01         ldx    #$01
  D6B2:  cde1c6       jsr    $E1C6
  D6B5:  a704         ais    #$04
  D6B7:  cdda3d       jsr    $DA3D
  D6BA:  cdda78       jsr    $DA78
  D6BD:  3fb6         clr    $B6
  D6BF:  3fb4         clr    $B4
  D6C1:  3fb5         clr    $B5
  D6C3:  4f           clra   
  D6C4:  c701d6       sta    $01D6
  D6C7:  3fb1         clr    $B1
  D6C9:  c701d7       sta    $01D7
  D6CC:  cdcf10       jsr    Sci_Init
  D6CF:  ccde04       jmp    $DE04

;---------------------------------------------------------------
; sub_D6D2   [0xD6D2]   <- CC74
;---------------------------------------------------------------
  D6D2:  87           psha   
  D6D3:  89           pshx   
  D6D4:  87           psha   
  D6D5:  cdd136       jsr    $D136
  D6D8:  c601e4       lda    $01E4
  D6DB:  415306       cbeqa  #$53, LD6E4
  D6DE:  5f           clrx   
  D6DF:  a621         lda    #$21
  D6E1:  cdca41       jsr    LinErr_Set
LD6E4:
  D6E4:  95           tsx    
  D6E5:  e602         lda    2,x
  D6E7:  410109       cbeqa  #$01, LD6F3
  D6EA:  410206       cbeqa  #$02, LD6F3
  D6ED:  5f           clrx   
  D6EE:  a603         lda    #$03
  D6F0:  cdca41       jsr    LinErr_Set
LD6F3:
  D6F3:  a601         lda    #$01
  D6F5:  95           tsx    
  D6F6:  f7           sta    ,x
  D6F7:  3dc5         tst    $C5
  D6F9:  261f         bne    LD71A
  D6FB:  e602         lda    2,x
  D6FD:  4b10         dbnza  LD70F
  D6FF:  a697         lda    #$97
  D701:  c701e3       sta    $01E3
  D704:  6e01c4       mov    #$01, $C4
  D707:  6e01c5       mov    #$01, $C5
  D70A:  cdde08       jsr    $DE08
  D70D:  2009         bra    LD718
LD70F:
  D70F:  cdddfe       jsr    LinSci_RxOn
  D712:  cddac5       jsr    $DAC5
  D715:  6ea1c1       mov    #$A1, $C1
LD718:
  D718:  95           tsx    
  D719:  7f           clr    ,x
LD71A:
  D71A:  cdd14e       jsr    $D14E
  D71D:  95           tsx    
  D71E:  f6           lda    ,x
  D71F:  a703         ais    #$03
  D721:  81           rts    

;---------------------------------------------------------------
; sub_D722   [0xD722]   <- CCD3
;---------------------------------------------------------------
  D722:  cdd136       jsr    $D136
  D725:  c601e4       lda    $01E4
  D728:  415306       cbeqa  #$53, LD731
  D72B:  5f           clrx   
  D72C:  a621         lda    #$21
  D72E:  cdca41       jsr    LinErr_Set
LD731:
  D731:  3dc2         tst    $C2
  D733:  272e         beq    LD763
  D735:  3bc22b       dbnz   $C2, LD763
  D738:  b6c5         lda    $C5
  D73A:  a101         cmp    #$01
  D73C:  2611         bne    LD74F
  D73E:  3fc5         clr    $C5
  D740:  a6ff         lda    #$FF
  D742:  87           psha   
  D743:  4f           clra   
  D744:  87           psha   
  D745:  5f           clrx   
  D746:  a60a         lda    #$0A
  D748:  cdca54       jsr    $CA54
  D74B:  a702         ais    #$02
  D74D:  2014         bra    LD763
LD74F:
  D74F:  a102         cmp    #$02
  D751:  2610         bne    LD763
  D753:  a6ff         lda    #$FF
  D755:  87           psha   
  D756:  4f           clra   
  D757:  87           psha   
  D758:  5f           clrx   
  D759:  a604         lda    #$04
  D75B:  cdca54       jsr    $CA54
  D75E:  a702         ais    #$02
  D760:  cddab6       jsr    $DAB6
LD763:
  D763:  3dc1         tst    $C1
  D765:  2713         beq    LD77A
  D767:  3bc110       dbnz   $C1, LD77A
  D76A:  a6ff         lda    #$FF
  D76C:  87           psha   
  D76D:  4f           clra   
  D76E:  87           psha   
  D76F:  5f           clrx   
  D770:  a603         lda    #$03
  D772:  cdca54       jsr    $CA54
  D775:  a702         ais    #$02
  D777:  cddab6       jsr    $DAB6
LD77A:
  D77A:  ccd14e       jmp    $D14E

;---------------------------------------------------------------
; sub_D77D   [0xD77D]   <- D863, D8D8
;---------------------------------------------------------------
  D77D:  87           psha   
  D77E:  89           pshx   
  D77F:  87           psha   
  D780:  95           tsx    
  D781:  7f           clr    ,x
  D782:  9ece01       ldhx   1,x
  D785:  6d01         tst    1,x
  D787:  2604         bne    LD78D
  D789:  f6           lda    ,x
  D78A:  41420a       cbeqa  #$42, LD797
LD78D:
  D78D:  e601         lda    1,x
  D78F:  a17f         cmp    #$7F
  D791:  261b         bne    LD7AE
  D793:  f6           lda    ,x
  D794:  4c           inca   
  D795:  2617         bne    LD7AE
LD797:
  D797:  6d03         tst    3,x
  D799:  2605         bne    LD7A0
  D79B:  e602         lda    2,x
  D79D:  410a0a       cbeqa  #$0A, LD7AA
LD7A0:
  D7A0:  e603         lda    3,x
  D7A2:  4c           inca   
  D7A3:  2609         bne    LD7AE
  D7A5:  e602         lda    2,x
  D7A7:  4c           inca   
  D7A8:  2604         bne    LD7AE
LD7AA:
  D7AA:  a601         lda    #$01
  D7AC:  95           tsx    
  D7AD:  f7           sta    ,x
LD7AE:
  D7AE:  95           tsx    
  D7AF:  f6           lda    ,x
  D7B0:  a703         ais    #$03
  D7B2:  81           rts    

;---------------------------------------------------------------
; sub_D7B3   [0xD7B3]   <- D8C4, DA2D
;---------------------------------------------------------------
  D7B3:  87           psha   
  D7B4:  89           pshx   
  D7B5:  95           tsx    
  D7B6:  e605         lda    5,x
  D7B8:  b7bd         sta    $BD
  D7BA:  e601         lda    1,x
  D7BC:  b7bc         sta    $BC
  D7BE:  6e7fbb       mov    #$7F, $BB
  D7C1:  6e03ba       mov    #$03, $BA
  D7C4:  c601e9       lda    $01E9
  D7C7:  b7b9         sta    $B9
  D7C9:  a702         ais    #$02
  D7CB:  81           rts    

;---------------------------------------------------------------
; sub_D7CC   [0xD7CC]   <- DC2B
;---------------------------------------------------------------
  D7CC:  87           psha   
  D7CD:  89           pshx   
  D7CE:  a7fc         ais    #$FC
  D7D0:  89           pshx   
  D7D1:  8a           pulh   
  D7D2:  97           tax    
  D7D3:  f6           lda    ,x
  D7D4:  a180         cmp    #$80
  D7D6:  2503         bcs    LD7DB
LD7D8:
  D7D8:  ccda34       jmp    $DA34
LD7DB:
  D7DB:  9efe05       ldhx   5,s
  D7DE:  e601         lda    1,x
  D7E0:  a107         cmp    #$07
  D7E2:  24f4         bcc    LD7D8
  D7E4:  a601         lda    #$01
  D7E6:  95           tsx    
  D7E7:  e703         sta    3,x
  D7E9:  3fb9         clr    $B9
  D7EB:  6e01ba       mov    #$01, $BA
  D7EE:  9ece04       ldhx   4,x
  D7F1:  e602         lda    2,x
  D7F3:  ab40         add    #$40
  D7F5:  b7bb         sta    $BB
  D7F7:  6effbc       mov    #$FF, $BC
  D7FA:  6effbd       mov    #$FF, $BD
  D7FD:  6effbe       mov    #$FF, $BE
  D800:  6effbf       mov    #$FF, $BF
  D803:  6effc0       mov    #$FF, $C0
  D806:  e602         lda    2,x
  D808:  a1b0         cmp    #$B0
  D80A:  25cc         bcs    LD7D8
  D80C:  a1b5         cmp    #$B5
  D80E:  24c8         bcc    LD7D8
  D810:  c601e9       lda    $01E9
  D813:  95           tsx    
  D814:  f7           sta    ,x
  D815:  9ece04       ldhx   4,x
  D818:  e602         lda    2,x
  D81A:  a1b0         cmp    #$B0
  D81C:  2604         bne    LD822
  D81E:  a60a         lda    #$0A
  D820:  95           tsx    
  D821:  f7           sta    ,x
LD822:
  D822:  9efe05       ldhx   5,s
  D825:  e601         lda    1,x
  D827:  a106         cmp    #$06
  D829:  2703         beq    LD82E
LD82B:
  D82B:  ccda37       jmp    $DA37
LD82E:
  D82E:  f6           lda    ,x
  D82F:  95           tsx    
  D830:  f1           cmp    ,x
  D831:  2708         beq    LD83B
  D833:  9ece04       ldhx   4,x
  D836:  f6           lda    ,x
  D837:  a17f         cmp    #$7F
  D839:  26f0         bne    LD82B
LD83B:
  D83B:  9efe05       ldhx   5,s
  D83E:  e602         lda    2,x
  D840:  41b01b       cbeqa  #$B0, LD85E
  D843:  41b132       cbeqa  #$B1, LD878
  D846:  a1b2         cmp    #$B2
  D848:  2603         bne    LD84D
  D84A:  ccd8d3       jmp    $D8D3
LD84D:
  D84D:  a1b3         cmp    #$B3
  D84F:  2603         bne    LD854
  D851:  ccd972       jmp    $D972
LD854:
  D854:  a1b4         cmp    #$B4
  D856:  2603         bne    LD85B
  D858:  ccda05       jmp    $DA05
LD85B:
  D85B:  ccda37       jmp    $DA37
LD85E:
  D85E:  af03         aix    #$03
  D860:  9f           txa    
  D861:  8b           pshh   
  D862:  88           pulx   
  D863:  cdd77d       jsr    $D77D
  D866:  95           tsx    
  D867:  f7           sta    ,x
  D868:  27f1         beq    LD85B
  D86A:  9ece04       ldhx   4,x
  D86D:  e607         lda    7,x
  D86F:  c701e9       sta    $01E9
  D872:  6e0ab9       mov    #$0A, $B9
LD875:
  D875:  ccda37       jmp    $DA37
LD878:
  D878:  6d04         tst    4,x
  D87A:  2605         bne    LD881
  D87C:  e603         lda    3,x
  D87E:  41420b       cbeqa  #$42, LD88C
LD881:
  D881:  e604         lda    4,x
  D883:  a17f         cmp    #$7F
  D885:  26ee         bne    LD875
  D887:  e603         lda    3,x
  D889:  4c           inca   
  D88A:  26e9         bne    LD875
LD88C:
  D88C:  e605         lda    5,x
  D88E:  95           tsx    
  D88F:  e702         sta    2,x
  D891:  9ece04       ldhx   4,x
  D894:  e606         lda    6,x
  D896:  95           tsx    
  D897:  e701         sta    1,x
  D899:  7f           clr    ,x
LD89A:
  D89A:  95           tsx    
  D89B:  fe           ldx    ,x
  D89C:  58           lslx   
  D89D:  8c           clrh   
  D89E:  9ebefed7     ldhx   $FED7,x
  D8A2:  9ef302       cphx   2,s
  D8A5:  260f         bne    LD8B6
  D8A7:  9efe05       ldhx   5,s
  D8AA:  e607         lda    7,x
  D8AC:  9eee01       ldx    1,s
  D8AF:  8c           clrh   
  D8B0:  d701e5       sta    $01E5,x
  D8B3:  ccda1e       jmp    $DA1E
LD8B6:
  D8B6:  95           tsx    
  D8B7:  f6           lda    ,x
  D8B8:  a103         cmp    #$03
  D8BA:  260d         bne    LD8C9
  D8BC:  a612         lda    #$12
  D8BE:  87           psha   
  D8BF:  4f           clra   
  D8C0:  87           psha   
  D8C1:  5f           clrx   
  D8C2:  a6b1         lda    #$B1
  D8C4:  cdd7b3       jsr    $D7B3
  D8C7:  a702         ais    #$02
LD8C9:
  D8C9:  95           tsx    
  D8CA:  7c           inc    ,x
  D8CB:  fe           ldx    ,x
  D8CC:  a304         cpx    #$04
  D8CE:  25ca         bcs    LD89A
LD8D0:
  D8D0:  ccda37       jmp    $DA37
LD8D3:
  D8D3:  af04         aix    #$04
  D8D5:  9f           txa    
  D8D6:  8b           pshh   
  D8D7:  88           pulx   
  D8D8:  cdd77d       jsr    $D77D
  D8DB:  95           tsx    
  D8DC:  f7           sta    ,x
  D8DD:  27f1         beq    LD8D0
  D8DF:  9ece04       ldhx   4,x
  D8E2:  e603         lda    3,x
  D8E4:  2611         bne    LD8F7
  D8E6:  3fc0         clr    $C0
  D8E8:  3fbf         clr    $BF
  D8EA:  6e0abe       mov    #$0A, $BE
  D8ED:  3fbd         clr    $BD
  D8EF:  6e42bc       mov    #$42, $BC
  D8F2:  6e06ba       mov    #$06, $BA
  D8F5:  2064         bra    LD95B
LD8F7:
  D8F7:  a101         cmp    #$01
  D8F9:  2610         bne    LD90B
  D8FB:  a6bc         lda    #$BC
  D8FD:  ae00         ldx    #$00
  D8FF:  cdcd18       jsr    $CD18
  D902:  95           tsx    
  D903:  f7           sta    ,x
  D904:  265a         bne    LD960
  D906:  6e05ba       mov    #$05, $BA
  D909:  2050         bra    LD95B
LD90B:
  D90B:  a110         cmp    #$10
  D90D:  2551         bcs    LD960
  D90F:  a120         cmp    #$20
  D911:  241f         bcc    LD932
  D913:  a114         cmp    #$14
  D915:  2449         bcc    LD960
  D917:  a010         sub    #$10
  D919:  95           tsx    
  D91A:  f7           sta    ,x
  D91B:  97           tax    
  D91C:  8c           clrh   
  D91D:  d601e5       lda    $01E5,x
  D920:  b7be         sta    $BE
  D922:  58           lslx   
  D923:  d6fed7       lda    $FED7,x
  D926:  b7bd         sta    $BD
  D928:  d6fed8       lda    $FED8,x
  D92B:  b7bc         sta    $BC
  D92D:  6e04ba       mov    #$04, $BA
  D930:  2029         bra    LD95B
LD932:
  D932:  a140         cmp    #$40
  D934:  242a         bcc    LD960
  D936:  4500bc       ldhx   #$00BC
  D939:  89           pshx   
  D93A:  8b           pshh   
  D93B:  9efe07       ldhx   7,s
  D93E:  e603         lda    3,x
  D940:  5f           clrx   
  D941:  cdcd15       jsr    $CD15
  D944:  a702         ais    #$02
  D946:  95           tsx    
  D947:  f7           sta    ,x
  D948:  a107         cmp    #$07
  D94A:  2506         bcs    LD952
  D94C:  5f           clrx   
  D94D:  a660         lda    #$60
  D94F:  cdca41       jsr    LinErr_Set
LD952:
  D952:  95           tsx    
  D953:  f6           lda    ,x
  D954:  270a         beq    LD960
  D956:  4c           inca   
  D957:  a40f         and    #$0F
  D959:  b7ba         sta    $BA
LD95B:
  D95B:  c601e9       lda    $01E9
  D95E:  b7b9         sta    $B9
LD960:
  D960:  3db9         tst    $B9
  D962:  2703         beq    LD967
  D964:  ccda37       jmp    $DA37
LD967:
  D967:  a612         lda    #$12
  D969:  87           psha   
  D96A:  4f           clra   
  D96B:  87           psha   
  D96C:  5f           clrx   
  D96D:  a6b2         lda    #$B2
  D96F:  ccda2d       jmp    $DA2D
LD972:
  D972:  e603         lda    3,x
  D974:  2623         bne    LD999
  D976:  e604         lda    4,x
  D978:  41010f       cbeqa  #$01, LD98A
  D97B:  410210       cbeqa  #$02, LD98E
  D97E:  41030f       cbeqa  #$03, LD990
  D981:  410410       cbeqa  #$04, LD994
  D984:  410510       cbeqa  #$05, LD997
LD987:
  D987:  ccda37       jmp    $DA37
LD98A:
  D98A:  a642         lda    #$42
  D98C:  204b         bra    LD9D9
LD98E:
  D98E:  2004         bra    LD994
LD990:
  D990:  a60a         lda    #$0A
  D992:  2045         bra    LD9D9
LD994:
  D994:  4f           clra   
  D995:  2042         bra    LD9D9
LD997:
  D997:  20fb         bra    LD994
LD999:
  D999:  a101         cmp    #$01
  D99B:  2615         bne    LD9B2
  D99D:  a6bc         lda    #$BC
  D99F:  ae00         ldx    #$00
  D9A1:  cdcd18       jsr    $CD18
  D9A4:  95           tsx    
  D9A5:  f7           sta    ,x
  D9A6:  26df         bne    LD987
  D9A8:  9ece04       ldhx   4,x
  D9AB:  ee04         ldx    4,x
  D9AD:  8c           clrh   
  D9AE:  e6bb         lda    187,x
  D9B0:  2027         bra    LD9D9
LD9B2:
  D9B2:  a110         cmp    #$10
  D9B4:  25d1         bcs    LD987
  D9B6:  a120         cmp    #$20
  D9B8:  247d         bcc    LDA37
  D9BA:  a114         cmp    #$14
  D9BC:  2479         bcc    LDA37
  D9BE:  a010         sub    #$10
  D9C0:  95           tsx    
  D9C1:  f7           sta    ,x
  D9C2:  9ece04       ldhx   4,x
  D9C5:  e604         lda    4,x
  D9C7:  410108       cbeqa  #$01, LD9D2
  D9CA:  410226       cbeqa  #$02, LD9F3
  D9CD:  41032d       cbeqa  #$03, LD9FD
  D9D0:  2065         bra    LDA37
LD9D2:
  D9D2:  95           tsx    
  D9D3:  fe           ldx    ,x
  D9D4:  58           lslx   
  D9D5:  8c           clrh   
  D9D6:  d6fed8       lda    $FED8,x
LD9D9:
  D9D9:  9efe05       ldhx   5,s
  D9DC:  e806         eor    6,x
  D9DE:  e405         and    5,x
  D9E0:  95           tsx    
  D9E1:  f7           sta    ,x
  D9E2:  2653         bne    LDA37
  D9E4:  c601e9       lda    $01E9
  D9E7:  b7b9         sta    $B9
  D9E9:  9ece04       ldhx   4,x
  D9EC:  e607         lda    7,x
  D9EE:  c701e9       sta    $01E9
  D9F1:  2044         bra    LDA37
LD9F3:
  D9F3:  95           tsx    
  D9F4:  fe           ldx    ,x
  D9F5:  58           lslx   
  D9F6:  8c           clrh   
  D9F7:  d6fed7       lda    $FED7,x
  D9FA:  5f           clrx   
  D9FB:  20dc         bra    LD9D9
LD9FD:
  D9FD:  95           tsx    
  D9FE:  fe           ldx    ,x
  D9FF:  8c           clrh   
  DA00:  d601e5       lda    $01E5,x
  DA03:  20d4         bra    LD9D9
LDA05:
  DA05:  4500bc       ldhx   #$00BC
  DA08:  89           pshx   
  DA09:  8b           pshh   
  DA0A:  9efe07       ldhx   7,s
  DA0D:  af03         aix    #$03
  DA0F:  9f           txa    
  DA10:  8b           pshh   
  DA11:  88           pulx   
  DA12:  cdcb41       jsr    $CB41
  DA15:  a702         ais    #$02
  DA17:  95           tsx    
  DA18:  f7           sta    ,x
  DA19:  260a         bne    LDA25
  DA1B:  6e06ba       mov    #$06, $BA
LDA1E:
  DA1E:  c601e9       lda    $01E9
  DA21:  b7b9         sta    $B9
  DA23:  2012         bra    LDA37
LDA25:
  DA25:  a611         lda    #$11
  DA27:  87           psha   
  DA28:  4f           clra   
  DA29:  87           psha   
  DA2A:  5f           clrx   
  DA2B:  a6b4         lda    #$B4
LDA2D:
  DA2D:  cdd7b3       jsr    $D7B3
  DA30:  a702         ais    #$02
  DA32:  2003         bra    LDA37
LDA34:
  DA34:  95           tsx    
  DA35:  6f03         clr    3,x
LDA37:
  DA37:  95           tsx    
  DA38:  e603         lda    3,x
  DA3A:  a706         ais    #$06
  DA3C:  81           rts    

;---------------------------------------------------------------
; sub_DA3D   [0xDA3D]   <- D6B7, DABD, DACE
;---------------------------------------------------------------
  DA3D:  87           psha   
  DA3E:  95           tsx    
  DA3F:  7f           clr    ,x
LDA40:
  DA40:  95           tsx    
  DA41:  fe           ldx    ,x
  DA42:  58           lslx   
  DA43:  8c           clrh   
  DA44:  9ebefee1     ldhx   $FEE1,x
  DA48:  2725         beq    LDA6F
  DA4A:  9eee01       ldx    1,s
  DA4D:  8c           clrh   
  DA4E:  d6fedf       lda    $FEDF,x
  DA51:  5f           clrx   
  DA52:  87           psha   
  DA53:  89           pshx   
  DA54:  9eee03       ldx    3,s
  DA57:  58           lslx   
  DA58:  d6ff0a       lda    $FF0A,x
  DA5B:  87           psha   
  DA5C:  d6ff09       lda    $FF09,x
  DA5F:  87           psha   
  DA60:  9eee05       ldx    5,s
  DA63:  58           lslx   
  DA64:  d6fee2       lda    $FEE2,x
  DA67:  defee1       ldx    $FEE1,x
  DA6A:  cde1c6       jsr    $E1C6
  DA6D:  a704         ais    #$04
LDA6F:
  DA6F:  95           tsx    
  DA70:  7c           inc    ,x
  DA71:  fe           ldx    ,x
  DA72:  a302         cpx    #$02
  DA74:  25ca         bcs    LDA40
  DA76:  8a           pulh   
  DA77:  81           rts    

;---------------------------------------------------------------
; sub_DA78   [0xDA78]   <- D6BA, DAC0, DAD1
;---------------------------------------------------------------
  DA78:  87           psha   
  DA79:  a602         lda    #$02
  DA7B:  95           tsx    
  DA7C:  f7           sta    ,x
LDA7D:
  DA7D:  97           tax    
  DA7E:  58           lslx   
  DA7F:  8c           clrh   
  DA80:  9ebefee1     ldhx   $FEE1,x
  DA84:  2727         beq    LDAAD
  DA86:  95           tsx    
  DA87:  fe           ldx    ,x
  DA88:  8c           clrh   
  DA89:  d6fed1       lda    $FED1,x
  DA8C:  62           nsa    
  DA8D:  a40f         and    #$0F
  DA8F:  5f           clrx   
  DA90:  87           psha   
  DA91:  89           pshx   
  DA92:  9eee03       ldx    3,s
  DA95:  58           lslx   
  DA96:  d6ff0a       lda    $FF0A,x
  DA99:  87           psha   
  DA9A:  d6ff09       lda    $FF09,x
  DA9D:  87           psha   
  DA9E:  9eee05       ldx    5,s
  DAA1:  58           lslx   
  DAA2:  d6fee2       lda    $FEE2,x
  DAA5:  defee1       ldx    $FEE1,x
  DAA8:  cde1c6       jsr    $E1C6
  DAAB:  a704         ais    #$04
LDAAD:
  DAAD:  95           tsx    
  DAAE:  7c           inc    ,x
  DAAF:  f6           lda    ,x
  DAB0:  a104         cmp    #$04
  DAB2:  25c9         bcs    LDA7D
  DAB4:  8a           pulh   
  DAB5:  81           rts    

;---------------------------------------------------------------
; sub_DAB6   [0xDAB6]   <- D760, D777, DC11
;---------------------------------------------------------------
  DAB6:  3fc5         clr    $C5
  DAB8:  3fc1         clr    $C1
  DABA:  cdca75       jsr    $CA75
  DABD:  cdda3d       jsr    $DA3D
  DAC0:  adb6         bsr    LDA78
  DAC2:  ccde04       jmp    $DE04

;---------------------------------------------------------------
; sub_DAC5   [0xDAC5]   <- D712
;---------------------------------------------------------------
  DAC5:  b6c5         lda    $C5
  DAC7:  2702         beq    LDACB
  DAC9:  4b0b         dbnza  LDAD6
LDACB:
  DACB:  6e02c5       mov    #$02, $C5
  DACE:  cdda3d       jsr    $DA3D
  DAD1:  ada5         bsr    LDA78
  DAD3:  cdca6b       jsr    $CA6B
LDAD6:
  DAD6:  81           rts    

;---------------------------------------------------------------
; Lin_GotoSleep2   [0xDAD7]   <- DEE1, DFE1
;---------------------------------------------------------------
  DAD7:  20ec         bra    LDAC5

;---------------------------------------------------------------
; LinSched_OnHeader   [0xDAD9]   <- DF09
;---------------------------------------------------------------
  DAD9:  87           psha   
  DADA:  89           pshx   
  DADB:  a7fd         ais    #$FD
  DADD:  a13c         cmp    #$3C
  DADF:  2604         bne    LDAE5
  DAE1:  a604         lda    #$04
  DAE3:  2021         bra    LDB06
LDAE5:
  DAE5:  a17d         cmp    #$7D
  DAE7:  2604         bne    LDAED
  DAE9:  a605         lda    #$05
  DAEB:  2019         bra    LDB06
LDAED:
  DAED:  a6ff         lda    #$FF
  DAEF:  95           tsx    
  DAF0:  e701         sta    1,x
  DAF2:  e604         lda    4,x
  DAF4:  414017       cbeqa  #$40, LDB0E
  DAF7:  a604         lda    #$04
  DAF9:  f7           sta    ,x
LDAFA:
  DAFA:  7a           dec    ,x
  DAFB:  fe           ldx    ,x
  DAFC:  8c           clrh   
  DAFD:  d601e5       lda    $01E5,x
  DB00:  95           tsx    
  DB01:  e104         cmp    4,x
  DB03:  2606         bne    LDB0B
  DB05:  f6           lda    ,x
LDB06:
  DB06:  95           tsx    
  DB07:  e701         sta    1,x
  DB09:  2003         bra    LDB0E
LDB0B:
  DB0B:  7d           tst    ,x
  DB0C:  26ec         bne    LDAFA
LDB0E:
  DB0E:  ee01         ldx    1,x
  DB10:  cf01e2       stx    $01E2
  DB13:  a3ff         cpx    #$FF
  DB15:  2607         bne    LDB1E
  DB17:  95           tsx    
  DB18:  e602         lda    2,x
  DB1A:  a40f         and    #$0F
  DB1C:  207b         bra    LDB99
LDB1E:
  DB1E:  8c           clrh   
  DB1F:  d6fed1       lda    $FED1,x
  DB22:  9ee703       sta    3,s
  DB25:  9ee602       lda    2,s
  DB28:  a104         cmp    #$04
  DB2A:  242a         bcc    LDB56
  DB2C:  9ee603       lda    3,s
  DB2F:  a40c         and    #$0C
  DB31:  a108         cmp    #$08
  DB33:  2668         bne    LDB9D
  DB35:  9eee02       ldx    2,s
  DB38:  58           lslx   
  DB39:  9ebefee1     ldhx   $FEE1,x
  DB3D:  275e         beq    LDB9D
  DB3F:  95           tsx    
  DB40:  e602         lda    2,x
  DB42:  62           nsa    
  DB43:  a40f         and    #$0F
  DB45:  5f           clrx   
  DB46:  87           psha   
  DB47:  89           pshx   
  DB48:  9eee04       ldx    4,s
  DB4B:  58           lslx   
  DB4C:  8c           clrh   
  DB4D:  d6fee2       lda    $FEE2,x
  DB50:  87           psha   
  DB51:  d6fee1       lda    $FEE1,x
  DB54:  2025         bra    LDB7B
LDB56:
  DB56:  a106         cmp    #$06
  DB58:  2443         bcc    LDB9D
  DB5A:  95           tsx    
  DB5B:  e602         lda    2,x
  DB5D:  a40c         and    #$0C
  DB5F:  a108         cmp    #$08
  DB61:  263a         bne    LDB9D
  DB63:  b6b8         lda    $B8
  DB65:  410205       cbeqa  #$02, LDB6D
  DB68:  41031c       cbeqa  #$03, LDB87
  DB6B:  202a         bra    LDB97
LDB6D:
  DB6D:  3db9         tst    $B9
  DB6F:  2726         beq    LDB97
  DB71:  a608         lda    #$08
  DB73:  87           psha   
  DB74:  4f           clra   
  DB75:  87           psha   
  DB76:  a6b9         lda    #$B9
  DB78:  87           psha   
  DB79:  a600         lda    #$00
LDB7B:
  DB7B:  87           psha   
  DB7C:  a6da         lda    #$DA
  DB7E:  ae01         ldx    #$01
  DB80:  cde188       jsr    $E188
  DB83:  a704         ais    #$04
  DB85:  2016         bra    LDB9D
LDB87:
  DB87:  cdd1fb       jsr    $D1FB
  DB8A:  95           tsx    
  DB8B:  f7           sta    ,x
  DB8C:  4b09         dbnza  LDB97
  DB8E:  a6da         lda    #$DA
  DB90:  ae01         ldx    #$01
  DB92:  cdd44c       jsr    $D44C
  DB95:  2006         bra    LDB9D
LDB97:
  DB97:  e602         lda    2,x
LDB99:
  DB99:  aa0c         ora    #$0C
  DB9B:  e702         sta    2,x
LDB9D:
  DB9D:  95           tsx    
  DB9E:  af02         aix    #$02
  DBA0:  f6           lda    ,x
  DBA1:  87           psha   
  DBA2:  cdde12       jsr    $DE12
  DBA5:  8a           pulh   
  DBA6:  b6c5         lda    $C5
  DBA8:  a102         cmp    #$02
  DBAA:  2608         bne    LDBB4
  DBAC:  6e0fc4       mov    #$0F, $C4
  DBAF:  3fc2         clr    $C2
  DBB1:  6e03c5       mov    #$03, $C5
LDBB4:
  DBB4:  a705         ais    #$05
  DBB6:  81           rts    

;---------------------------------------------------------------
; LinDiag_Response   [0xDBB7]   <- DF63, DFA8
;---------------------------------------------------------------
  DBB7:  87           psha   
  DBB8:  89           pshx   
  DBB9:  a7fd         ais    #$FD
  DBBB:  4501da       ldhx   #$01DA
  DBBE:  9eff02       sthx   2,s
  DBC1:  e608         lda    8,x
  DBC3:  95           tsx    
  DBC4:  f7           sta    ,x
  DBC5:  e604         lda    4,x
  DBC7:  4a           deca   
  DBC8:  2703         beq    LDBCD
  DBCA:  ccdc6e       jmp    $DC6E
LDBCD:
  DBCD:  f6           lda    ,x
  DBCE:  a104         cmp    #$04
  DBD0:  2435         bcc    LDC07
  DBD2:  97           tax    
  DBD3:  58           lslx   
  DBD4:  8c           clrh   
  DBD5:  9ebefee1     ldhx   $FEE1,x
  DBD9:  271f         beq    LDBFA
  DBDB:  97           tax    
  DBDC:  8c           clrh   
  DBDD:  d6fedf       lda    $FEDF,x
  DBE0:  5f           clrx   
  DBE1:  87           psha   
  DBE2:  89           pshx   
  DBE3:  9ee605       lda    5,s
  DBE6:  87           psha   
  DBE7:  9ee605       lda    5,s
  DBEA:  87           psha   
  DBEB:  9eee05       ldx    5,s
  DBEE:  58           lslx   
  DBEF:  d6fee2       lda    $FEE2,x
  DBF2:  defee1       ldx    $FEE1,x
  DBF5:  cde188       jsr    $E188
  DBF8:  a704         ais    #$04
LDBFA:
  DBFA:  95           tsx    
  DBFB:  fe           ldx    ,x
  DBFC:  8c           clrh   
  DBFD:  b6c8         lda    $C8
  DBFF:  dafeec       ora    $FEEC,x
  DC02:  b7c8         sta    $C8
LDC04:
  DC04:  ccdcc8       jmp    $DCC8
LDC07:
  DC07:  a106         cmp    #$06
  DC09:  24f9         bcc    LDC04
  DC0B:  9efe02       ldhx   2,s
  DC0E:  7d           tst    ,x
  DC0F:  260e         bne    LDC1F
  DC11:  cddab6       jsr    $DAB6
  DC14:  6e02b8       mov    #$02, $B8
  DC17:  a602         lda    #$02
  DC19:  c701d9       sta    $01D9
  DC1C:  ccdcc8       jmp    $DCC8
LDC1F:
  DC1F:  b6c8         lda    $C8
  DC21:  cafeee       ora    $FEEE
  DC24:  b7c8         sta    $C8
  DC26:  95           tsx    
  DC27:  e602         lda    2,x
  DC29:  ee01         ldx    1,x
  DC2B:  cdd7cc       jsr    $D7CC
  DC2E:  95           tsx    
  DC2F:  f7           sta    ,x
  DC30:  4b0c         dbnza  LDC3E
  DC32:  c601d9       lda    $01D9
  DC35:  a103         cmp    #$03
  DC37:  2626         bne    LDC5F
  DC39:  cdd61d       jsr    $D61D
  DC3C:  2021         bra    LDC5F
LDC3E:
  DC3E:  e602         lda    2,x
  DC40:  ee01         ldx    1,x
  DC42:  cdd20d       jsr    $D20D
  DC45:  95           tsx    
  DC46:  f7           sta    ,x
  DC47:  a101         cmp    #$01
  DC49:  2604         bne    LDC4F
  DC4B:  a603         lda    #$03
  DC4D:  2012         bra    LDC61
LDC4F:
  DC4F:  a102         cmp    #$02
  DC51:  2608         bne    LDC5B
  DC53:  c701d9       sta    $01D9
  DC56:  6e03b8       mov    #$03, $B8
  DC59:  206d         bra    LDCC8
LDC5B:
  DC5B:  a103         cmp    #$03
  DC5D:  2607         bne    LDC66
LDC5F:
  DC5F:  a602         lda    #$02
LDC61:
  DC61:  c701d9       sta    $01D9
  DC64:  205f         bra    LDCC5
LDC66:
  DC66:  4f           clra   
  DC67:  c701d9       sta    $01D9
  DC6A:  3fb8         clr    $B8
  DC6C:  205a         bra    LDCC8
LDC6E:
  DC6E:  f6           lda    ,x
  DC6F:  a104         cmp    #$04
  DC71:  2438         bcc    LDCAB
  DC73:  a103         cmp    #$03
  DC75:  2609         bne    LDC80
  DC77:  32fee7       ldhx   $FEE7
  DC7A:  e607         lda    7,x
  DC7C:  a47f         and    #$7F
  DC7E:  e707         sta    7,x
LDC80:
  DC80:  95           tsx    
  DC81:  fe           ldx    ,x
  DC82:  8c           clrh   
  DC83:  b6c6         lda    $C6
  DC85:  dafef0       ora    $FEF0,x
  DC88:  b7c6         sta    $C6
  DC8A:  9f           txa    
  DC8B:  48           lsla   
  DC8C:  a004         sub    #$04
  DC8E:  97           tax    
  DC8F:  9ebefef5     ldhx   $FEF5,x
  DC93:  2733         beq    LDCC8
  DC95:  95           tsx    
  DC96:  f6           lda    ,x
  DC97:  5f           clrx   
  DC98:  87           psha   
  DC99:  89           pshx   
  DC9A:  95           tsx    
  DC9B:  e602         lda    2,x
  DC9D:  48           lsla   
  DC9E:  a004         sub    #$04
  DCA0:  8c           clrh   
  DCA1:  97           tax    
  DCA2:  9ebefef5     ldhx   $FEF5,x
  DCA6:  cdfcd8       jsr    $FCD8
  DCA9:  201d         bra    LDCC8
LDCAB:
  DCAB:  b6c6         lda    $C6
  DCAD:  cafef4       ora    $FEF4
  DCB0:  b7c6         sta    $C6
  DCB2:  b6b8         lda    $B8
  DCB4:  a102         cmp    #$02
  DCB6:  2602         bne    LDCBA
  DCB8:  3fb9         clr    $B9
LDCBA:
  DCBA:  a103         cmp    #$03
  DCBC:  260a         bne    LDCC8
  DCBE:  cdd5c7       jsr    $D5C7
  DCC1:  a103         cmp    #$03
  DCC3:  2603         bne    LDCC8
LDCC5:
  DCC5:  6e02b8       mov    #$02, $B8
LDCC8:
  DCC8:  a705         ais    #$05
  DCCA:  81           rts    

;---------------------------------------------------------------
; LinErr_Report   [0xDCCB]   <- DDB8, DEF0, DF47, DFB0, DFF7, E018, E020
;---------------------------------------------------------------
  DCCB:  87           psha   
  DCCC:  89           pshx   
  DCCD:  87           psha   
  DCCE:  a5f0         bit    #$F0
  DCD0:  2603         bne    LDCD5
  DCD2:  ccdd56       jmp    $DD56
LDCD5:
  DCD5:  c601e2       lda    $01E2
  DCD8:  95           tsx    
  DCD9:  f7           sta    ,x
  DCDA:  32fee7       ldhx   $FEE7
  DCDD:  e607         lda    7,x
  DCDF:  aa80         ora    #$80
  DCE1:  e707         sta    7,x
  DCE3:  95           tsx    
  DCE4:  f6           lda    ,x
  DCE5:  a104         cmp    #$04
  DCE7:  261f         bne    LDD08
  DCE9:  b6b8         lda    $B8
  DCEB:  a102         cmp    #$02
  DCED:  2602         bne    LDCF1
  DCEF:  3fb9         clr    $B9
LDCF1:
  DCF1:  410307       cbeqa  #$03, LDCFB
  DCF4:  c601d9       lda    $01D9
  DCF7:  a103         cmp    #$03
  DCF9:  2608         bne    LDD03
LDCFB:
  DCFB:  a602         lda    #$02
  DCFD:  c701d9       sta    $01D9
  DD00:  cdd61d       jsr    $D61D
LDD03:
  DD03:  6e02b8       mov    #$02, $B8
  DD06:  95           tsx    
  DD07:  f6           lda    ,x
LDD08:
  DD08:  a105         cmp    #$05
  DD0A:  2616         bne    LDD22
  DD0C:  b6b8         lda    $B8
  DD0E:  a103         cmp    #$03
  DD10:  260a         bne    LDD1C
  DD12:  a602         lda    #$02
  DD14:  c701d9       sta    $01D9
  DD17:  cdd61d       jsr    $D61D
  DD1A:  b6b8         lda    $B8
LDD1C:
  DD1C:  a102         cmp    #$02
  DD1E:  2602         bne    LDD22
  DD20:  3fb9         clr    $B9
LDD22:
  DD22:  95           tsx    
  DD23:  e602         lda    2,x
  DD25:  41110e       cbeqa  #$11, LDD36
  DD28:  41120b       cbeqa  #$12, LDD36
  DD2B:  411310       cbeqa  #$13, LDD3E
  DD2E:  411415       cbeqa  #$14, LDD46
  DD31:  41161a       cbeqa  #$16, LDD4E
  DD34:  2033         bra    LDD69
LDD36:
  DD36:  f6           lda    ,x
  DD37:  5f           clrx   
  DD38:  87           psha   
  DD39:  89           pshx   
  DD3A:  a608         lda    #$08
  DD3C:  2026         bra    LDD64
LDD3E:
  DD3E:  f6           lda    ,x
  DD3F:  5f           clrx   
  DD40:  87           psha   
  DD41:  89           pshx   
  DD42:  a609         lda    #$09
  DD44:  201e         bra    LDD64
LDD46:
  DD46:  f6           lda    ,x
  DD47:  5f           clrx   
  DD48:  87           psha   
  DD49:  89           pshx   
  DD4A:  a607         lda    #$07
  DD4C:  2016         bra    LDD64
LDD4E:
  DD4E:  f6           lda    ,x
  DD4F:  5f           clrx   
  DD50:  87           psha   
  DD51:  89           pshx   
  DD52:  a602         lda    #$02
  DD54:  200e         bra    LDD64
LDD56:
  DD56:  410504       cbeqa  #$05, LDD5D
  DD59:  a107         cmp    #$07
  DD5B:  260c         bne    LDD69
LDD5D:
  DD5D:  a6ff         lda    #$FF
  DD5F:  87           psha   
  DD60:  4f           clra   
  DD61:  87           psha   
  DD62:  5f           clrx   
  DD63:  4c           inca   
LDD64:
  DD64:  cdca54       jsr    $CA54
  DD67:  a702         ais    #$02
LDD69:
  DD69:  a703         ais    #$03
  DD6B:  81           rts    

;---------------------------------------------------------------
; LinTp_Timer   [0xDD6C]   <- C781
;---------------------------------------------------------------
  DD6C:  cdd136       jsr    $D136
  DD6F:  b6b1         lda    $B1
  DD71:  410f20       cbeqa  #$0F, LDD94
  DD74:  411105       cbeqa  #$11, LDD7C
  DD77:  41230d       cbeqa  #$23, LDD87
  DD7A:  201e         bra    LDD9A
LDD7C:
  DD7C:  c601d6       lda    $01D6
  DD7F:  c701d7       sta    $01D7
  DD82:  6e10b1       mov    #$10, $B1
  DD85:  2013         bra    LDD9A
LDD87:
  DD87:  c601d6       lda    $01D6
  DD8A:  4501d7       ldhx   #$01D7
  DD8D:  fb           add    ,x
  DD8E:  f7           sta    ,x
  DD8F:  6e20b1       mov    #$20, $B1
  DD92:  2006         bra    LDD9A
LDD94:
  DD94:  4f           clra   
  DD95:  c701d7       sta    $01D7
  DD98:  3fb1         clr    $B1
LDD9A:
  DD9A:  c601d7       lda    $01D7
  DD9D:  2720         beq    LDDBF
  DD9F:  4501d7       ldhx   #$01D7
  DDA2:  7a           dec    ,x
  DDA3:  f6           lda    ,x
  DDA4:  2619         bne    LDDBF
  DDA6:  b6b1         lda    $B1
  DDA8:  a110         cmp    #$10
  DDAA:  2605         bne    LDDB1
  DDAC:  5f           clrx   
  DDAD:  a605         lda    #$05
  DDAF:  2007         bra    LDDB8
LDDB1:
  DDB1:  a120         cmp    #$20
  DDB3:  2606         bne    LDDBB
  DDB5:  5f           clrx   
  DDB6:  a616         lda    #$16
LDDB8:
  DDB8:  cddccb       jsr    LinErr_Report
LDDBB:
  DDBB:  3fb1         clr    $B1
  DDBD:  ad3f         bsr    LinSci_RxOn
LDDBF:
  DDBF:  b6c4         lda    $C4
  DDC1:  410105       cbeqa  #$01, LDDC9
  DDC4:  410f0c       cbeqa  #$0F, LDDD3
  DDC7:  200e         bra    LDDD7
LDDC9:
  DDC9:  c601e3       lda    $01E3
  DDCC:  b7c3         sta    $C3
  DDCE:  6e11c4       mov    #$11, $C4
  DDD1:  2004         bra    LDDD7
LDDD3:
  DDD3:  3fc3         clr    $C3
  DDD5:  3fc4         clr    $C4
LDDD7:
  DDD7:  3dc3         tst    $C3
  DDD9:  2720         beq    LDDFB
  DDDB:  3bc31d       dbnz   $C3, LDDFB
  DDDE:  b6c4         lda    $C4
  DDE0:  411108       cbeqa  #$11, LDDEB
  DDE3:  411205       cbeqa  #$12, LDDEB
  DDE6:  41130d       cbeqa  #$13, LDDF6
  DDE9:  2010         bra    LDDFB
LDDEB:
  DDEB:  3cc4         inc    $C4
  DDED:  6e97c3       mov    #$97, $C3
  DDF0:  ad12         bsr    LDE04
  DDF2:  ad14         bsr    LDE08
  DDF4:  2005         bra    LDDFB
LDDF6:
  DDF6:  3fc4         clr    $C4
  DDF8:  6e3dc2       mov    #$3D, $C2
LDDFB:
  DDFB:  ccd14e       jmp    $D14E

;---------------------------------------------------------------
; LinSci_RxOn   [0xDDFE]   <- D70F, DDBD, DE81, DEDE, DEF3, DF4A, DF52, DF94
;---------------------------------------------------------------
  DDFE:  6e80b7       mov    #$80, $B7
  DE01:  ccd126       jmp    $D126

;---------------------------------------------------------------
; sub_DE04   [0xDE04]   <- DDF0
;---------------------------------------------------------------
  DE04:  6effb7       mov    #$FF, $B7
  DE07:  81           rts    

;---------------------------------------------------------------
; sub_DE08   [0xDE08]   <- D70A, DDF2
;---------------------------------------------------------------
  DE08:  5f           clrx   
  DE09:  a680         lda    #$80
  DE0B:  cdcf36       jsr    Sci_SendByte
  DE0E:  6effb7       mov    #$FF, $B7
  DE11:  81           rts    

;---------------------------------------------------------------
; sub_DE12   [0xDE12]   <- DBA2
;---------------------------------------------------------------
  DE12:  4501da       ldhx   #$01DA
  DE15:  35b2         sthx   $B2
  DE17:  95           tsx    
  DE18:  e602         lda    2,x
  DE1A:  62           nsa    
  DE1B:  a40f         and    #$0F
  DE1D:  b7b6         sta    $B6
  DE1F:  e602         lda    2,x
  DE21:  a501         bit    #$01
  DE23:  270a         beq    LDE2F
  DE25:  c601d8       lda    $01D8
  DE28:  5f           clrx   
  DE29:  b7b5         sta    $B5
  DE2B:  bfb4         stx    $B4
  DE2D:  2004         bra    LDE33
LDE2F:
  DE2F:  3fb4         clr    $B4
  DE31:  3fb5         clr    $B5
LDE33:
  DE33:  beb6         ldx    $B6
  DE35:  8c           clrh   
  DE36:  d6fec4       lda    $FEC4,x
  DE39:  c701d6       sta    $01D6
  DE3C:  6e23b1       mov    #$23, $B1
  DE3F:  9ee603       lda    3,s
  DE42:  a40c         and    #$0C
  DE44:  a108         cmp    #$08
  DE46:  2622         bne    LDE6A
  DE48:  3db6         tst    $B6
  DE4A:  2606         bne    LDE52
  DE4C:  5f           clrx   
  DE4D:  a60b         lda    #$0B
  DE4F:  cdca41       jsr    LinErr_Set
LDE52:
  DE52:  55b2         ldhx   $B2
  DE54:  f6           lda    ,x
  DE55:  5f           clrx   
  DE56:  cdcf36       jsr    Sci_SendByte
  DE59:  55b2         ldhx   $B2
  DE5B:  b6b5         lda    $B5
  DE5D:  fb           add    ,x
  DE5E:  5f           clrx   
  DE5F:  b7b5         sta    $B5
  DE61:  4f           clra   
  DE62:  b9b4         adc    $B4
  DE64:  b7b4         sta    $B4
  DE66:  6e01b7       mov    #$01, $B7
  DE69:  81           rts    
LDE6A:
  DE6A:  9ee603       lda    3,s
  DE6D:  a40c         and    #$0C
  DE6F:  a104         cmp    #$04
  DE71:  260e         bne    LDE81
  DE73:  3db6         tst    $B6
  DE75:  2606         bne    LDE7D
  DE77:  5f           clrx   
  DE78:  a60b         lda    #$0B
  DE7A:  cdca41       jsr    LinErr_Set
LDE7D:
  DE7D:  6e08b7       mov    #$08, $B7
  DE80:  81           rts    
LDE81:
  DE81:  cdddfe       jsr    LinSci_RxOn
  DE84:  6e0fb1       mov    #$0F, $B1
  DE87:  81           rts    

;---------------------------------------------------------------
; LinCrc_Fold   [0xDE88]   <- DF35, DF9A
;---------------------------------------------------------------
  DE88:  a7fe         ais    #$FE
  DE8A:  beb4         ldx    $B4
  DE8C:  9eef02       stx    2,s
  DE8F:  95           tsx    
  DE90:  7f           clr    ,x
  DE91:  b6b5         lda    $B5
  DE93:  eb01         add    1,x
  DE95:  b7b5         sta    $B5
  DE97:  4f           clra   
  DE98:  f9           adc    ,x
  DE99:  b7b4         sta    $B4
  DE9B:  2706         beq    LDEA3
  DE9D:  55b4         ldhx   $B4
  DE9F:  af01         aix    #$01
  DEA1:  35b4         sthx   $B4
LDEA3:
  DEA3:  a702         ais    #$02
  DEA5:  81           rts    

;---------------------------------------------------------------
; Lin_RxByte   [0xDEA6]   <- CF70
;---------------------------------------------------------------
  DEA6:  87           psha   
  DEA7:  89           pshx   
  DEA8:  6ea1c1       mov    #$A1, $C1
  DEAB:  b6b7         lda    $B7
  DEAD:  41015f       cbeqa  #$01, LDF0F
  DEB0:  a102         cmp    #$02
  DEB2:  2603         bne    LDEB7
  DEB4:  ccdf52       jmp    $DF52
LDEB7:
  DEB7:  a108         cmp    #$08
  DEB9:  2603         bne    LDEBE
  DEBB:  ccdf6d       jmp    $DF6D
LDEBE:
  DEBE:  a109         cmp    #$09
  DEC0:  2603         bne    LDEC5
  DEC2:  ccdf94       jmp    $DF94
LDEC5:
  DEC5:  a180         cmp    #$80
  DEC7:  2603         bne    LDECC
  DEC9:  ccdfb3       jmp    $DFB3
LDECC:
  DECC:  419018       cbeqa  #$90, LDEE7
  DECF:  41b030       cbeqa  #$B0, LDF02
  DED2:  41ff09       cbeqa  #$FF, LDEDE
  DED5:  5f           clrx   
  DED6:  a60b         lda    #$0B
  DED8:  cdca41       jsr    LinErr_Set
  DEDB:  ccdfb3       jmp    $DFB3
LDEDE:
  DEDE:  cdddfe       jsr    LinSci_RxOn
  DEE1:  cddad7       jsr    Lin_GotoSleep2
  DEE4:  ccdfb3       jmp    $DFB3
LDEE7:
  DEE7:  95           tsx    
  DEE8:  e601         lda    1,x
  DEEA:  41550f       cbeqa  #$55, LDEFC
  DEED:  5f           clrx   
  DEEE:  a603         lda    #$03
  DEF0:  cddccb       jsr    LinErr_Report
  DEF3:  cdddfe       jsr    LinSci_RxOn
  DEF6:  6e0fb1       mov    #$0F, $B1
  DEF9:  ccdfb3       jmp    $DFB3
LDEFC:
  DEFC:  6eb0b7       mov    #$B0, $B7
  DEFF:  ccdfb3       jmp    $DFB3
LDF02:
  DF02:  95           tsx    
  DF03:  e601         lda    1,x
  DF05:  c701d8       sta    $01D8
  DF08:  5f           clrx   
  DF09:  cddad9       jsr    LinSched_OnHeader
  DF0C:  ccdfb3       jmp    $DFB3
LDF0F:
  DF0F:  55b2         ldhx   $B2
  DF11:  f6           lda    ,x
  DF12:  95           tsx    
  DF13:  e101         cmp    1,x
  DF15:  262d         bne    LDF44
  DF17:  3ab6         dec    $B6
  DF19:  271a         beq    LDF35
  DF1B:  55b2         ldhx   $B2
  DF1D:  af01         aix    #$01
  DF1F:  35b2         sthx   $B2
  DF21:  f6           lda    ,x
  DF22:  5f           clrx   
  DF23:  cdcf36       jsr    Sci_SendByte
  DF26:  55b2         ldhx   $B2
  DF28:  b6b5         lda    $B5
  DF2A:  fb           add    ,x
  DF2B:  5f           clrx   
  DF2C:  b7b5         sta    $B5
  DF2E:  4f           clra   
  DF2F:  b9b4         adc    $B4
  DF31:  b7b4         sta    $B4
  DF33:  207e         bra    LDFB3
LDF35:
  DF35:  cdde88       jsr    LinCrc_Fold
  DF38:  b6b5         lda    $B5
  DF3A:  43           coma   
  DF3B:  5f           clrx   
  DF3C:  cdcf36       jsr    Sci_SendByte
  DF3F:  6e02b7       mov    #$02, $B7
  DF42:  206f         bra    LDFB3
LDF44:
  DF44:  5f           clrx   
  DF45:  a611         lda    #$11
  DF47:  cddccb       jsr    LinErr_Report
  DF4A:  cdddfe       jsr    LinSci_RxOn
  DF4D:  6e0fb1       mov    #$0F, $B1
  DF50:  2061         bra    LDFB3
LDF52:
  DF52:  cdddfe       jsr    LinSci_RxOn
  DF55:  6e0fb1       mov    #$0F, $B1
  DF58:  b6b5         lda    $B5
  DF5A:  43           coma   
  DF5B:  95           tsx    
  DF5C:  e101         cmp    1,x
  DF5E:  2608         bne    LDF68
  DF60:  5f           clrx   
  DF61:  a602         lda    #$02
  DF63:  cddbb7       jsr    LinDiag_Response
  DF66:  204b         bra    LDFB3
LDF68:
  DF68:  5f           clrx   
  DF69:  a611         lda    #$11
  DF6B:  2043         bra    LDFB0
LDF6D:
  DF6D:  3db6         tst    $B6
  DF6F:  2606         bne    LDF77
  DF71:  5f           clrx   
  DF72:  a60b         lda    #$0B
  DF74:  cdca41       jsr    LinErr_Set
LDF77:
  DF77:  b6b5         lda    $B5
  DF79:  95           tsx    
  DF7A:  eb01         add    1,x
  DF7C:  b7b5         sta    $B5
  DF7E:  4f           clra   
  DF7F:  b9b4         adc    $B4
  DF81:  b7b4         sta    $B4
  DF83:  e601         lda    1,x
  DF85:  55b2         ldhx   $B2
  DF87:  f7           sta    ,x
  DF88:  af01         aix    #$01
  DF8A:  35b2         sthx   $B2
  DF8C:  3bb624       dbnz   $B6, LDFB3
  DF8F:  6e09b7       mov    #$09, $B7
  DF92:  201f         bra    LDFB3
LDF94:
  DF94:  cdddfe       jsr    LinSci_RxOn
  DF97:  6e0fb1       mov    #$0F, $B1
  DF9A:  cdde88       jsr    LinCrc_Fold
  DF9D:  b6b5         lda    $B5
  DF9F:  43           coma   
  DFA0:  95           tsx    
  DFA1:  e101         cmp    1,x
  DFA3:  2608         bne    LDFAD
  DFA5:  5f           clrx   
  DFA6:  a601         lda    #$01
  DFA8:  cddbb7       jsr    LinDiag_Response
  DFAB:  2006         bra    LDFB3
LDFAD:
  DFAD:  5f           clrx   
  DFAE:  a614         lda    #$14
LDFB0:
  DFB0:  cddccb       jsr    LinErr_Report
LDFB3:
  DFB3:  a702         ais    #$02
  DFB5:  81           rts    

;---------------------------------------------------------------
; Lin_TxByteOrErr   [0xDFB6]   <- CF90
;---------------------------------------------------------------
  DFB6:  87           psha   
  DFB7:  89           pshx   
  DFB8:  6ea1c1       mov    #$A1, $C1
  DFBB:  b6b7         lda    $B7
  DFBD:  410134       cbeqa  #$01, LDFF4
  DFC0:  410231       cbeqa  #$02, LDFF4
  DFC3:  a108         cmp    #$08
  DFC5:  2747         beq    LE00E
  DFC7:  410944       cbeqa  #$09, LE00E
  DFCA:  418019       cbeqa  #$80, LDFE6
  DFCD:  41901f       cbeqa  #$90, LDFEF
  DFD0:  41b01c       cbeqa  #$B0, LDFEF
  DFD3:  41ff08       cbeqa  #$FF, LDFDE
  DFD6:  5f           clrx   
  DFD7:  a60b         lda    #$0B
  DFD9:  cdca41       jsr    LinErr_Set
  DFDC:  204b         bra    LE029
LDFDE:
  DFDE:  cdddfe       jsr    LinSci_RxOn
  DFE1:  cddad7       jsr    Lin_GotoSleep2
  DFE4:  2043         bra    LE029
LDFE6:
  DFE6:  95           tsx    
  DFE7:  e601         lda    1,x
  DFE9:  a102         cmp    #$02
  DFEB:  263c         bne    LE029
  DFED:  2012         bra    LE001
LDFEF:
  DFEF:  5f           clrx   
  DFF0:  a607         lda    #$07
  DFF2:  2003         bra    LDFF7
LDFF4:
  DFF4:  5f           clrx   
  DFF5:  a612         lda    #$12
LDFF7:
  DFF7:  cddccb       jsr    LinErr_Report
  DFFA:  9ee602       lda    2,s
  DFFD:  a102         cmp    #$02
  DFFF:  2622         bne    LE023
LE001:
  E001:  6e90b7       mov    #$90, $B7
  E004:  a604         lda    #$04
  E006:  c701d6       sta    $01D6
  E009:  6e11b1       mov    #$11, $B1
  E00C:  201b         bra    LE029
LE00E:
  E00E:  95           tsx    
  E00F:  e601         lda    1,x
  E011:  a102         cmp    #$02
  E013:  2608         bne    LE01D
  E015:  5f           clrx   
  E016:  a613         lda    #$13
  E018:  cddccb       jsr    LinErr_Report
  E01B:  20e4         bra    LE001
LE01D:
  E01D:  5f           clrx   
  E01E:  a613         lda    #$13
  E020:  cddccb       jsr    LinErr_Report
LE023:
  E023:  cdddfe       jsr    LinSci_RxOn
  E026:  6e0fb1       mov    #$0F, $B1
LE029:
  E029:  a702         ais    #$02
  E02B:  81           rts    

;---------------------------------------------------------------
; sub_E02C   [0xE02C]   <- CC67
;---------------------------------------------------------------
  E02C:  c601ea       lda    $01EA
  E02F:  a4fc         and    #$FC
  E031:  aa08         ora    #$08
  E033:  c701ea       sta    $01EA
  E036:  81           rts    

;---------------------------------------------------------------
; sub_E037   [0xE037]   <- CD0A
;---------------------------------------------------------------
  E037:  c601ea       lda    $01EA
  E03A:  a501         bit    #$01
  E03C:  2714         beq    LE052
  E03E:  a4fe         and    #$FE
  E040:  c701ea       sta    $01EA
  E043:  c601ed       lda    $01ED
  E046:  a122         cmp    #$22
  E048:  2603         bne    LE04D
  E04A:  ccca87       jmp    $CA87
LE04D:
  E04D:  5f           clrx   
  E04E:  a611         lda    #$11
  E050:  ad31         bsr    LE083
LE052:
  E052:  81           rts    
;   .... data/gap E053-E083 ....

;---------------------------------------------------------------
; sub_E083   [0xE083]   <- CB3B, E050
;---------------------------------------------------------------
  E083:  87           psha   
  E084:  89           pshx   
  E085:  c601ed       lda    $01ED
  E088:  c701ee       sta    $01EE
  E08B:  a67f         lda    #$7F
  E08D:  c701ed       sta    $01ED
  E090:  95           tsx    
  E091:  e601         lda    1,x
  E093:  c701ef       sta    $01EF
  E096:  a603         lda    #$03
  E098:  c701ec       sta    $01EC
  E09B:  4f           clra   
  E09C:  c701eb       sta    $01EB
  E09F:  ad7d         bsr    LE11E
  E0A1:  a702         ais    #$02
  E0A3:  81           rts    
;   .... data/gap E0A4-E0AE ....

;---------------------------------------------------------------
; sub_E0AE   [0xE0AE]   <- D296, D321
;---------------------------------------------------------------
  E0AE:  87           psha   
  E0AF:  89           pshx   
  E0B0:  87           psha   
  E0B1:  95           tsx    
  E0B2:  7f           clr    ,x
  E0B3:  c601ea       lda    $01EA
  E0B6:  a502         bit    #$02
  E0B8:  262d         bne    LE0E7
  E0BA:  9ece05       ldhx   5,x
  E0BD:  9601eb       sthx   $01EB
  E0C0:  95           tsx    
  E0C1:  e602         lda    2,x
  E0C3:  a17e         cmp    #$7E
  E0C5:  2607         bne    LE0CE
  E0C7:  c601ea       lda    $01EA
  E0CA:  a4fb         and    #$FB
  E0CC:  2005         bra    LE0D3
LE0CE:
  E0CE:  c601ea       lda    $01EA
  E0D1:  aa04         ora    #$04
LE0D3:
  E0D3:  c701ea       sta    $01EA
  E0D6:  9efe06       ldhx   6,s
  E0D9:  650041       cphx   #$0041
  E0DC:  2409         bcc    LE0E7
  E0DE:  aa02         ora    #$02
  E0E0:  c701ea       sta    $01EA
  E0E3:  a601         lda    #$01
  E0E5:  95           tsx    
  E0E6:  f7           sta    ,x
LE0E7:
  E0E7:  95           tsx    
  E0E8:  f6           lda    ,x
  E0E9:  a703         ais    #$03
  E0EB:  81           rts    

;---------------------------------------------------------------
; sub_E0EC   [0xE0EC]   <- D1C0, D260, D2C1, D2F5, D3DD, D435
;---------------------------------------------------------------
  E0EC:  87           psha   
  E0ED:  89           pshx   
  E0EE:  c601ed       lda    $01ED
  E0F1:  a540         bit    #$40
  E0F3:  2614         bne    LE109
  E0F5:  95           tsx    
  E0F6:  6d01         tst    1,x
  E0F8:  260f         bne    LE109
  E0FA:  3201eb       ldhx   $01EB
  E0FD:  afff         aix    #$FF
  E0FF:  9601eb       sthx   $01EB
  E102:  c601ea       lda    $01EA
  E105:  aa09         ora    #$09
  E107:  2005         bra    LE10E
LE109:
  E109:  c601ea       lda    $01EA
  E10C:  a4fd         and    #$FD
LE10E:
  E10E:  c701ea       sta    $01EA
  E111:  a702         ais    #$02
  E113:  81           rts    

;---------------------------------------------------------------
; sub_E114   [0xE114]   <- D1AD, D278, D306, D5DA, D60F, D639
;---------------------------------------------------------------
  E114:  c601ea       lda    $01EA
  E117:  a4fd         and    #$FD
  E119:  c701ea       sta    $01EA
  E11C:  4f           clra   
  E11D:  81           rts    

;---------------------------------------------------------------
; sub_E11E   [0xE11E]   <- E09F
;---------------------------------------------------------------
  E11E:  c601ea       lda    $01EA
  E121:  a504         bit    #$04
  E123:  2709         beq    LE12E
  E125:  c601ec       lda    $01EC
  E128:  ce01eb       ldx    $01EB
  E12B:  ccd1c6       jmp    $D1C6
LE12E:
  E12E:  5f           clrx   
  E12F:  4f           clra   
  E130:  20e2         bra    LE114
;   .... data/gap E132-E13A ....

;---------------------------------------------------------------
; sub_E13A   [0xE13A]   <- D4AB, D566
;---------------------------------------------------------------
  E13A:  87           psha   
  E13B:  89           pshx   
  E13C:  2016         bra    LE154
LE13E:
  E13E:  afff         aix    #$FF
  E140:  9eff07       sthx   7,s
  E143:  95           tsx    
  E144:  e601         lda    1,x
  E146:  eb07         add    7,x
  E148:  87           psha   
  E149:  f6           lda    ,x
  E14A:  95           tsx    
  E14B:  e907         adc    7,x
  E14D:  87           psha   
  E14E:  8a           pulh   
  E14F:  88           pulx   
  E150:  9ee606       lda    6,s
  E153:  f7           sta    ,x
LE154:
  E154:  9efe07       ldhx   7,s
  E157:  26e5         bne    LE13E
  E159:  a702         ais    #$02
  E15B:  81           rts    

;---------------------------------------------------------------
; sub_E15C   [0xE15C]   <- D668, D676
;---------------------------------------------------------------
  E15C:  8b           pshh   
  E15D:  87           psha   
  E15E:  89           pshx   
  E15F:  87           psha   
  E160:  89           pshx   
  E161:  8a           pulh   
  E162:  88           pulx   
  E163:  2003         bra    LE168
LE165:
  E165:  7f           clr    ,x
  E166:  af01         aix    #$01
LE168:
  E168:  9ee607       lda    7,s
  E16B:  2706         beq    LE173
  E16D:  4a           deca   
  E16E:  9ee707       sta    7,s
  E171:  20f2         bra    LE165
LE173:
  E173:  9ee606       lda    6,s
  E176:  270b         beq    LE183
  E178:  4a           deca   
  E179:  9ee706       sta    6,s
  E17C:  4f           clra   
  E17D:  4a           deca   
  E17E:  9ee707       sta    7,s
  E181:  20e2         bra    LE165
LE183:
  E183:  88           pulx   
  E184:  86           pula   
  E185:  8a           pulh   
  E186:  81           rts    
;   .... data/gap E187-E188 ....

;---------------------------------------------------------------
; sub_E188   [0xE188]   <- D2BA, D345, D3BF, D402, D488, D4E2, D545, D598
;---------------------------------------------------------------
  E188:  8b           pshh   
  E189:  87           psha   
  E18A:  89           pshx   
  E18B:  201a         bra    LE1A7
LE18D:
  E18D:  9eee06       ldx    6,s
  E190:  89           pshx   
  E191:  8a           pulh   
  E192:  9eee07       ldx    7,s
  E195:  f6           lda    ,x
  E196:  af01         aix    #$01
  E198:  9eef07       stx    7,s
  E19B:  8b           pshh   
  E19C:  88           pulx   
  E19D:  9eef06       stx    6,s
  E1A0:  8a           pulh   
  E1A1:  88           pulx   
  E1A2:  f7           sta    ,x
  E1A3:  af01         aix    #$01
  E1A5:  89           pshx   
  E1A6:  8b           pshh   
LE1A7:
  E1A7:  9eee09       ldx    9,s
  E1AA:  2706         beq    LE1B2
  E1AC:  5a           decx   
  E1AD:  9eef09       stx    9,s
  E1B0:  20db         bra    LE18D
LE1B2:
  E1B2:  9ee608       lda    8,s
  E1B5:  270a         beq    LE1C1
  E1B7:  4a           deca   
  E1B8:  9ee708       sta    8,s
  E1BB:  5a           decx   
  E1BC:  9eef09       stx    9,s
  E1BF:  20cc         bra    LE18D
LE1C1:
  E1C1:  88           pulx   
  E1C2:  86           pula   
  E1C3:  8a           pulh   
  E1C4:  81           rts    
;   .... data/gap E1C5-E1C6 ....

;---------------------------------------------------------------
; sub_E1C6   [0xE1C6]   <- D6B2, DA6A, DAA8
;---------------------------------------------------------------
  E1C6:  87           psha   
  E1C7:  89           pshx   
  E1C8:  2021         bra    LE1EB
LE1CA:
  E1CA:  afff         aix    #$FF
  E1CC:  9eff07       sthx   7,s
  E1CF:  95           tsx    
  E1D0:  e601         lda    1,x
  E1D2:  eb07         add    7,x
  E1D4:  87           psha   
  E1D5:  f6           lda    ,x
  E1D6:  95           tsx    
  E1D7:  e907         adc    7,x
  E1D9:  87           psha   
  E1DA:  e606         lda    6,x
  E1DC:  eb08         add    8,x
  E1DE:  87           psha   
  E1DF:  e605         lda    5,x
  E1E1:  95           tsx    
  E1E2:  e909         adc    9,x
  E1E4:  87           psha   
  E1E5:  8a           pulh   
  E1E6:  88           pulx   
  E1E7:  f6           lda    ,x
  E1E8:  8a           pulh   
  E1E9:  88           pulx   
  E1EA:  f7           sta    ,x
LE1EB:
  E1EB:  9efe07       ldhx   7,s
  E1EE:  26da         bne    LE1CA
  E1F0:  a702         ais    #$02
  E1F2:  81           rts    
;   .... data/gap E1F3-E229 ....

;---------------------------------------------------------------
; Sensor_Init   [0xE229]   <- C57D
;---------------------------------------------------------------
  E229:  a641         lda    #$41
  E22B:  c70016       sta    ADC1CFG
  E22E:  4f           clra   
  E22F:  c70011       sta    ADC1SC2
  E232:  a60f         lda    #$0F
  E234:  c70017       sta    APCTL1
  E237:  44           lsra   
  E238:  c70018       sta    APCTL2
  E23B:  4f           clra   
  E23C:  c70019       sta    APCTL3
  E23F:  c70015       sta    ADC1CVL
  E242:  c70014       sta    ADC1CVH
  E245:  81           rts    

;---------------------------------------------------------------
; Adc_Read   [0xE246]   <- E2FF, E692, E6A1, E6EC, E6FB, E72F, E73E, E768
;---------------------------------------------------------------
  E246:  87           psha   
  E247:  89           pshx   
  E248:  87           psha   
  E249:  a41f         and    #$1F
  E24B:  95           tsx    
  E24C:  e702         sta    2,x
  E24E:  411f18       cbeqa  #$1F, LE269
  E251:  c70010       sta    ADC1SC1
  E254:  5f           clrx   
  E255:  a602         lda    #$02
  E257:  cdf497       jsr    Delay_Loop
  E25A:  2001         bra    LE25D
LE25C:
  E25C:  7f           clr    ,x
LE25D:
  E25D:  c60010       lda    ADC1SC1
  E260:  95           tsx    
  E261:  2af9         bpl    LE25C
  E263:  7f           clr    ,x
  E264:  c60013       lda    ADC1RL
  E267:  2005         bra    LE26E
LE269:
  E269:  c70010       sta    ADC1SC1
  E26C:  a6ff         lda    #$FF
LE26E:
  E26E:  a703         ais    #$03
  E270:  81           rts    

;---------------------------------------------------------------
; sub_E271   [0xE271]   <- C571
;---------------------------------------------------------------
  E271:  4f           clra   
  E272:  c7026c       sta    $026C
  E275:  c7026d       sta    $026D
  E278:  4c           inca   
  E279:  c70265       sta    $0265
  E27C:  81           rts    

;---------------------------------------------------------------
; sub_E27D   [0xE27D]   <- E7BA, F83E, F897
;---------------------------------------------------------------
  E27D:  a7fe         ais    #$FE
  E27F:  4f           clra   
  E280:  c70265       sta    $0265
  E283:  c60267       lda    $0267
  E286:  a1d1         cmp    #$D1
  E288:  2507         bcs    LE291
  E28A:  c6026e       lda    $026E
  E28D:  a103         cmp    #$03
  E28F:  245f         bcc    LE2F0
LE291:
  E291:  c6019a       lda    $019A
  E294:  4b47         dbnza  LE2DD
  E296:  c60267       lda    $0267
  E299:  ae5a         ldx    #$5A
  E29B:  42           mul    
  E29C:  bfce         stx    g_scratch
  E29E:  8c           clrh   
  E29F:  aea6         ldx    #$A6
  E2A1:  cdfd08       jsr    $FD08
  E2A4:  a01a         sub    #$1A
  E2A6:  2402         bcc    LE2AA
  E2A8:  3ace         dec    g_scratch
LE2AA:
  E2AA:  97           tax    
  E2AB:  b6ce         lda    g_scratch
  E2AD:  87           psha   
  E2AE:  8a           pulh   
  E2AF:  a640         lda    #$40
  E2B1:  b7ce         sta    g_scratch
  E2B3:  4f           clra   
  E2B4:  cdfe2a       jsr    $FE2A
  E2B7:  ce026e       ldx    $026E
  E2BA:  8c           clrh   
  E2BB:  cdfd5b       jsr    $FD5B
  E2BE:  95           tsx    
  E2BF:  e701         sta    1,x
  E2C1:  bece         ldx    g_scratch
  E2C3:  9eef01       stx    1,s
  E2C6:  cdfe77       jsr    $FE77
  E2C9:  45ff21       ldhx   #$FF21
  E2CC:  cdfdfc       jsr    $FDFC
  E2CF:  9104         blt    LE2D5
  E2D1:  a6c8         lda    #$C8
  E2D3:  201d         bra    LE2F2
LE2D5:
  E2D5:  9efe01       ldhx   1,s
  E2D8:  96026c       sthx   $026C
  E2DB:  200b         bra    LE2E8
LE2DD:
  E2DD:  ce026e       ldx    $026E
  E2E0:  58           lslx   
  E2E1:  4f           clra   
  E2E2:  c7026d       sta    $026D
  E2E5:  cf026c       stx    $026C
LE2E8:
  E2E8:  a601         lda    #$01
  E2EA:  c70265       sta    $0265
  E2ED:  a702         ais    #$02
  E2EF:  81           rts    
LE2F0:
  E2F0:  a604         lda    #$04
LE2F2:
  E2F2:  c7026c       sta    $026C
  E2F5:  4f           clra   
  E2F6:  c7026d       sta    $026D
  E2F9:  20ed         bra    LE2E8

;---------------------------------------------------------------
; sub_E2FB   [0xE2FB]   <- C583
;---------------------------------------------------------------
  E2FB:  87           psha   
  E2FC:  5f           clrx   
  E2FD:  a60a         lda    #$0A
  E2FF:  cde246       jsr    Adc_Read
  E302:  95           tsx    
  E303:  f7           sta    ,x
  E304:  a1d1         cmp    #$D1
  E306:  2423         bcc    LE32B
  E308:  a16f         cmp    #$6F
  E30A:  251f         bcs    LE32B
  E30C:  cde6e4       jsr    $E6E4
  E30F:  4d           tsta   
  E310:  2710         beq    LE322
  E312:  cde67f       jsr    $E67F
  E315:  4d           tsta   
  E316:  2714         beq    LE32C
  E318:  95           tsx    
  E319:  f6           lda    ,x
  E31A:  a1d1         cmp    #$D1
  E31C:  2414         bcc    LE332
  E31E:  a16f         cmp    #$6F
  E320:  2510         bcs    LE332
LE322:
  E322:  a608         lda    #$08
  E324:  c70233       sta    $0233
  E327:  a601         lda    #$01
  E329:  2004         bra    LE32F
LE32B:
  E32B:  4f           clra   
LE32C:
  E32C:  c70233       sta    $0233
LE32F:
  E32F:  c7029e       sta    $029E
LE332:
  E332:  cde649       jsr    $E649
  E335:  8a           pulh   
  E336:  81           rts    

;---------------------------------------------------------------
; sub_E337   [0xE337]   <- C654
;---------------------------------------------------------------
  E337:  c6019c       lda    $019C
  E33A:  a401         and    #$01
  E33C:  2606         bne    LE344
  E33E:  a601         lda    #$01
  E340:  c7029e       sta    $029E
  E343:  81           rts    
LE344:
  E344:  ad02         bsr    LE348
  E346:  2016         bra    LE35E

;---------------------------------------------------------------
; sub_E348   [0xE348]   <- E344
;---------------------------------------------------------------
  E348:  320231       ldhx   $0231
  E34B:  65ffff       cphx   #$FFFF
  E34E:  2406         bcc    LE356
  E350:  af01         aix    #$01
  E352:  960231       sthx   $0231
  E355:  81           rts    
LE356:
  E356:  4f           clra   
  E357:  c70231       sta    $0231
  E35A:  c70232       sta    $0232
  E35D:  81           rts    
LE35E:
  E35E:  87           psha   
  E35F:  c60233       lda    $0233
  E362:  a109         cmp    #$09
  E364:  2503         bcs    LE369
  E366:  cce505       jmp    $E505
LE369:
  E369:  cdfd76       jsr    switch_jump
;   .... data/gap E36C-E381 ....
LE381:
  E381:  cde649       jsr    $E649
  E384:  c602b2       lda    $02B2
  E387:  4b34         dbnza  LE3BD
  E389:  c602b1       lda    $02B1
  E38C:  4b2f         dbnza  LE3BD
  E38E:  c60267       lda    $0267
  E391:  a16f         cmp    #$6F
  E393:  2528         bcs    LE3BD
  E395:  a1d1         cmp    #$D1
  E397:  2424         bcc    LE3BD
  E399:  c602ae       lda    $02AE
  E39C:  270b         beq    LE3A9
  E39E:  c602af       lda    $02AF
  E3A1:  ab0a         add    #$0A
  E3A3:  5f           clrx   
  E3A4:  cde5a7       jsr    $E5A7
  E3A7:  2009         bra    LE3B2
LE3A9:
  E3A9:  a60f         lda    #$0F
  E3AB:  c70232       sta    $0232
  E3AE:  4f           clra   
  E3AF:  c70231       sta    $0231
LE3B2:
  E3B2:  a601         lda    #$01
  E3B4:  c70233       sta    $0233
  E3B7:  cde50f       jsr    $E50F
LE3BA:
  E3BA:  cce50c       jmp    $E50C
LE3BD:
  E3BD:  c602b3       lda    $02B3
  E3C0:  4b15         dbnza  LE3D7
  E3C2:  c60230       lda    $0230
  E3C5:  2610         bne    LE3D7
  E3C7:  c60267       lda    $0267
  E3CA:  a16f         cmp    #$6F
  E3CC:  2509         bcs    LE3D7
  E3CE:  a1d1         cmp    #$D1
  E3D0:  2405         bcc    LE3D7
  E3D2:  a606         lda    #$06
  E3D4:  c70233       sta    $0233
LE3D7:
  E3D7:  c602b3       lda    $02B3
  E3DA:  26de         bne    LE3BA
  E3DC:  c70230       sta    $0230
LE3DF:
  E3DF:  cce50c       jmp    $E50C
LE3E2:
  E3E2:  320231       ldhx   $0231
  E3E5:  65000f       cphx   #$000F
  E3E8:  240d         bcc    LE3F7
  E3EA:  c602ae       lda    $02AE
  E3ED:  99           sec    
  E3EE:  c20232       sbc    $0232
  E3F1:  4f           clra   
  E3F2:  c20231       sbc    $0231
  E3F5:  24e8         bcc    LE3DF
LE3F7:
  E3F7:  c602b0       lda    $02B0
  E3FA:  a40f         and    #$0F
  E3FC:  ab61         add    #$61
  E3FE:  8c           clrh   
  E3FF:  97           tax    
  E400:  d60120       lda    $0120,x
  E403:  c7022f       sta    $022F
  E406:  5f           clrx   
  E407:  cde5ec       jsr    $E5EC
  E40A:  cde50f       jsr    $E50F
  E40D:  a602         lda    #$02
  E40F:  c70233       sta    $0233
LE412:
  E412:  cce50c       jmp    $E50C
LE415:
  E415:  c60180       lda    $0180
  E418:  5f           clrx   
  E419:  48           lsla   
  E41A:  59           rolx   
  E41B:  48           lsla   
  E41C:  59           rolx   
  E41D:  99           sec    
  E41E:  c20232       sbc    $0232
  E421:  9f           txa    
  E422:  c20231       sbc    $0231
  E425:  2405         bcc    LE42C
  E427:  c60180       lda    $0180
  E42A:  2605         bne    LE431
LE42C:
  E42C:  c602b2       lda    $02B2
  E42F:  26e1         bne    LE412
LE431:
  E431:  cde649       jsr    $E649
  E434:  5f           clrx   
  E435:  a6fa         lda    #$FA
  E437:  cdf497       jsr    Delay_Loop
  E43A:  cde631       jsr    $E631
  E43D:  cde50f       jsr    $E50F
  E440:  a603         lda    #$03
  E442:  c70233       sta    $0233
  E445:  cce50c       jmp    $E50C
LE448:
  E448:  cde661       jsr    $E661
  E44B:  95           tsx    
  E44C:  f7           sta    ,x
  E44D:  270b         beq    LE45A
  E44F:  a608         lda    #$08
  E451:  c70233       sta    $0233
  E454:  cde649       jsr    $E649
  E457:  cce50c       jmp    $E50C
LE45A:
  E45A:  320231       ldhx   $0231
  E45D:  650032       cphx   #$0032
  E460:  250b         bcs    LE46D
  E462:  cde649       jsr    $E649
  E465:  a605         lda    #$05
  E467:  c70233       sta    $0233
LE46A:
  E46A:  cce50c       jmp    $E50C
LE46D:
  E46D:  c602b2       lda    $02B2
  E470:  26f8         bne    LE46A
  E472:  a604         lda    #$04
  E474:  c70233       sta    $0233
  E477:  cce50c       jmp    $E50C
LE47A:
  E47A:  c602b2       lda    $02B2
  E47D:  4b1b         dbnza  LE49A
  E47F:  cde649       jsr    $E649
  E482:  5f           clrx   
  E483:  a6fa         lda    #$FA
  E485:  cdf497       jsr    Delay_Loop
  E488:  c602af       lda    $02AF
  E48B:  ab0a         add    #$0A
  E48D:  5f           clrx   
  E48E:  cde5a7       jsr    $E5A7
  E491:  ad7c         bsr    LE50F
  E493:  a601         lda    #$01
  E495:  c70233       sta    $0233
  E498:  2072         bra    LE50C
LE49A:
  E49A:  320231       ldhx   $0231
  E49D:  650032       cphx   #$0032
  E4A0:  256a         bcs    LE50C
  E4A2:  cde649       jsr    $E649
  E4A5:  4f           clra   
  E4A6:  c70233       sta    $0233
  E4A9:  2061         bra    LE50C
LE4AB:
  E4AB:  c602b2       lda    $02B2
  E4AE:  2608         bne    LE4B8
  E4B0:  c70233       sta    $0233
  E4B3:  cde649       jsr    $E649
  E4B6:  2054         bra    LE50C
LE4B8:
  E4B8:  c602b3       lda    $02B3
  E4BB:  4b0a         dbnza  LE4C7
  E4BD:  c60230       lda    $0230
  E4C0:  2605         bne    LE4C7
  E4C2:  a606         lda    #$06
  E4C4:  c70233       sta    $0233
LE4C7:
  E4C7:  c602b3       lda    $02B3
  E4CA:  2640         bne    LE50C
  E4CC:  c70230       sta    $0230
LE4CF:
  E4CF:  203b         bra    LE50C
LE4D1:
  E4D1:  cde6e4       jsr    $E6E4
  E4D4:  cde67f       jsr    $E67F
  E4D7:  cde661       jsr    $E661
  E4DA:  95           tsx    
  E4DB:  f7           sta    ,x
  E4DC:  270c         beq    LE4EA
  E4DE:  cde649       jsr    $E649
  E4E1:  a601         lda    #$01
  E4E3:  c7029e       sta    $029E
  E4E6:  a608         lda    #$08
  E4E8:  2007         bra    LE4F1
LE4EA:
  E4EA:  c7029e       sta    $029E
  E4ED:  cde649       jsr    $E649
  E4F0:  4f           clra   
LE4F1:
  E4F1:  c70233       sta    $0233
  E4F4:  a601         lda    #$01
  E4F6:  c70230       sta    $0230
  E4F9:  2011         bra    LE50C
LE4FB:
  E4FB:  cde649       jsr    $E649
  E4FE:  a601         lda    #$01
  E500:  c7029e       sta    $029E
  E503:  2007         bra    LE50C
LE505:
  E505:  cde649       jsr    $E649
  E508:  4f           clra   
  E509:  c70233       sta    $0233
LE50C:
  E50C:  8a           pulh   
  E50D:  81           rts    
;   .... data/gap E50E-E50F ....

;---------------------------------------------------------------
; sub_E50F   [0xE50F]   <- E3B7, E40A, E43D, E491
;---------------------------------------------------------------
  E50F:  4f           clra   
  E510:  c70231       sta    $0231
  E513:  c70232       sta    $0232
  E516:  81           rts    

;---------------------------------------------------------------
; sub_E517   [0xE517]   <- C586
;---------------------------------------------------------------
  E517:  4f           clra   
  E518:  c7023b       sta    $023B
  E51B:  c7023a       sta    $023A
  E51E:  c70238       sta    $0238
  E521:  c70237       sta    $0237
  E524:  4c           inca   
  E525:  c70235       sta    $0235
  E528:  a6ff         lda    #$FF
  E52A:  c70236       sta    $0236
  E52D:  4f           clra   
  E52E:  c70239       sta    $0239
  E531:  cde65c       jsr    $E65C
  E534:  cce649       jmp    $E649

;---------------------------------------------------------------
; Scan_Isr   [0xE537]   <- C788
;---------------------------------------------------------------
  E537:  c60239       lda    $0239
  E53A:  2739         beq    LE575
  E53C:  c60238       lda    $0238
  E53F:  c1023a       cmp    $023A
  E542:  241a         bcc    LE55E
  E544:  c1023b       cmp    $023B
  E547:  450008       ldhx   #$0008
  E54A:  2405         bcc    LE551
  E54C:  f6           lda    ,x
  E54D:  aa04         ora    #$04
  E54F:  2003         bra    LE554
LE551:
  E551:  f6           lda    ,x
  E552:  a4fb         and    #$FB
LE554:
  E554:  f7           sta    ,x
  E555:  45000a       ldhx   #$000A
  E558:  f6           lda    ,x
  E559:  a4ef         and    #$EF
  E55B:  f7           sta    ,x
  E55C:  2012         bra    LE570
LE55E:
  E55E:  450008       ldhx   #$0008
  E561:  f6           lda    ,x
  E562:  aa04         ora    #$04
  E564:  f7           sta    ,x
  E565:  45000a       ldhx   #$000A
  E568:  f6           lda    ,x
  E569:  a4ef         and    #$EF
  E56B:  f7           sta    ,x
  E56C:  4f           clra   
  E56D:  c70238       sta    $0238
LE570:
  E570:  450238       ldhx   #$0238
  E573:  7c           inc    ,x
  E574:  81           rts    
LE575:
  E575:  c60237       lda    $0237
  E578:  a102         cmp    #$02
  E57A:  2513         bcs    LE58F
  E57C:  450008       ldhx   #$0008
  E57F:  f6           lda    ,x
  E580:  a4fb         and    #$FB
  E582:  f7           sta    ,x
  E583:  45000a       ldhx   #$000A
  E586:  f6           lda    ,x
  E587:  a4ef         and    #$EF
  E589:  f7           sta    ,x
  E58A:  450237       ldhx   #$0237
  E58D:  7a           dec    ,x
  E58E:  81           rts    
LE58F:
  E58F:  4b15         dbnza  LE5A6
  E591:  cde729       jsr    $E729
  E594:  450008       ldhx   #$0008
  E597:  f6           lda    ,x
  E598:  a4fb         and    #$FB
  E59A:  f7           sta    ,x
  E59B:  45000a       ldhx   #$000A
  E59E:  f6           lda    ,x
  E59F:  aa10         ora    #$10
  E5A1:  f7           sta    ,x
  E5A2:  4f           clra   
  E5A3:  c70237       sta    $0237
LE5A6:
  E5A6:  81           rts    

;---------------------------------------------------------------
; sub_E5A7   [0xE5A7]   <- E3A4, E48E
;---------------------------------------------------------------
  E5A7:  87           psha   
  E5A8:  89           pshx   
  E5A9:  a11a         cmp    #$1A
  E5AB:  2432         bcc    LE5DF
  E5AD:  4d           tsta   
  E5AE:  271c         beq    LE5CC
  E5B0:  a601         lda    #$01
  E5B2:  c70239       sta    $0239
  E5B5:  95           tsx    
  E5B6:  e601         lda    1,x
  E5B8:  c7023b       sta    $023B
  E5BB:  a619         lda    #$19
  E5BD:  c7023a       sta    $023A
  E5C0:  4f           clra   
  E5C1:  c70238       sta    $0238
  E5C4:  450008       ldhx   #$0008
  E5C7:  f6           lda    ,x
  E5C8:  aa04         ora    #$04
  E5CA:  2009         bra    LE5D5
LE5CC:
  E5CC:  c70239       sta    $0239
  E5CF:  450008       ldhx   #$0008
  E5D2:  f6           lda    ,x
  E5D3:  a4fb         and    #$FB
LE5D5:
  E5D5:  f7           sta    ,x
  E5D6:  45000a       ldhx   #$000A
  E5D9:  f6           lda    ,x
  E5DA:  a4ef         and    #$EF
  E5DC:  f7           sta    ,x
  E5DD:  200a         bra    LE5E9
LE5DF:
  E5DF:  a60a         lda    #$0A
  E5E1:  c7023b       sta    $023B
  E5E4:  a619         lda    #$19
  E5E6:  c7023a       sta    $023A
LE5E9:
  E5E9:  a702         ais    #$02
  E5EB:  81           rts    

;---------------------------------------------------------------
; sub_E5EC   [0xE5EC]   <- E407
;---------------------------------------------------------------
  E5EC:  87           psha   
  E5ED:  89           pshx   
  E5EE:  a115         cmp    #$15
  E5F0:  2432         bcc    LE624
  E5F2:  4d           tsta   
  E5F3:  271c         beq    LE611
  E5F5:  a601         lda    #$01
  E5F7:  c70239       sta    $0239
  E5FA:  95           tsx    
  E5FB:  e601         lda    1,x
  E5FD:  c7023b       sta    $023B
  E600:  a614         lda    #$14
  E602:  c7023a       sta    $023A
  E605:  4f           clra   
  E606:  c70238       sta    $0238
  E609:  450008       ldhx   #$0008
  E60C:  f6           lda    ,x
  E60D:  aa04         ora    #$04
  E60F:  2009         bra    LE61A
LE611:
  E611:  c70239       sta    $0239
  E614:  450008       ldhx   #$0008
  E617:  f6           lda    ,x
  E618:  a4fb         and    #$FB
LE61A:
  E61A:  f7           sta    ,x
  E61B:  45000a       ldhx   #$000A
  E61E:  f6           lda    ,x
  E61F:  a4ef         and    #$EF
  E621:  f7           sta    ,x
  E622:  200a         bra    LE62E
LE624:
  E624:  a60c         lda    #$0C
  E626:  c7023b       sta    $023B
  E629:  a614         lda    #$14
  E62B:  c7023a       sta    $023A
LE62E:
  E62E:  a702         ais    #$02
  E630:  81           rts    

;---------------------------------------------------------------
; sub_E631   [0xE631]   <- E43A
;---------------------------------------------------------------
  E631:  4f           clra   
  E632:  c70239       sta    $0239
  E635:  450008       ldhx   #$0008
  E638:  f6           lda    ,x
  E639:  a4fb         and    #$FB
  E63B:  f7           sta    ,x
  E63C:  45000a       ldhx   #$000A
  E63F:  f6           lda    ,x
  E640:  a4ef         and    #$EF
  E642:  f7           sta    ,x
  E643:  a604         lda    #$04
  E645:  c70237       sta    $0237
  E648:  81           rts    

;---------------------------------------------------------------
; sub_E649   [0xE649]   <- E332, E381, E431, E454, E462, E47F, E4A2, E4B3
;---------------------------------------------------------------
  E649:  4f           clra   
  E64A:  c70239       sta    $0239
  E64D:  450008       ldhx   #$0008
  E650:  f6           lda    ,x
  E651:  a4fb         and    #$FB
  E653:  f7           sta    ,x
  E654:  45000a       ldhx   #$000A
  E657:  f6           lda    ,x
  E658:  a4ef         and    #$EF
  E65A:  f7           sta    ,x
  E65B:  81           rts    

;---------------------------------------------------------------
; sub_E65C   [0xE65C]   <- E531
;---------------------------------------------------------------
  E65C:  4f           clra   
  E65D:  c70234       sta    $0234
  E660:  81           rts    

;---------------------------------------------------------------
; sub_E661   [0xE661]   <- E448, E4D7
;---------------------------------------------------------------
  E661:  ce0236       ldx    $0236
  E664:  2710         beq    LE676
  E666:  c60235       lda    $0235
  E669:  8c           clrh   
  E66A:  52           div    
  E66B:  a108         cmp    #$08
  E66D:  c60234       lda    $0234
  E670:  2407         bcc    LE679
  E672:  a4fd         and    #$FD
  E674:  2005         bra    LE67B
LE676:
  E676:  c60234       lda    $0234
LE679:
  E679:  aa02         ora    #$02
LE67B:
  E67B:  c70234       sta    $0234
  E67E:  81           rts    

;---------------------------------------------------------------
; sub_E67F   [0xE67F]   <- E312, E4D4
;---------------------------------------------------------------
  E67F:  a7fe         ais    #$FE
  E681:  450008       ldhx   #$0008
  E684:  f6           lda    ,x
  E685:  aa04         ora    #$04
  E687:  f7           sta    ,x
  E688:  45000a       ldhx   #$000A
  E68B:  f6           lda    ,x
  E68C:  a4ef         and    #$EF
  E68E:  f7           sta    ,x
  E68F:  5f           clrx   
  E690:  a60a         lda    #$0A
  E692:  cde246       jsr    Adc_Read
  E695:  95           tsx    
  E696:  e701         sta    1,x
  E698:  5f           clrx   
  E699:  a6f0         lda    #$F0
  E69B:  cdf497       jsr    Delay_Loop
  E69E:  5f           clrx   
  E69F:  a602         lda    #$02
  E6A1:  cde246       jsr    Adc_Read
  E6A4:  c70235       sta    $0235
  E6A7:  c60234       lda    $0234
  E6AA:  aa01         ora    #$01
  E6AC:  c70234       sta    $0234
  E6AF:  a601         lda    #$01
  E6B1:  95           tsx    
  E6B2:  f7           sta    ,x
  E6B3:  c60235       lda    $0235
  E6B6:  2724         beq    LE6DC
  E6B8:  e601         lda    1,x
  E6BA:  5f           clrx   
  E6BB:  48           lsla   
  E6BC:  59           rolx   
  E6BD:  48           lsla   
  E6BE:  59           rolx   
  E6BF:  48           lsla   
  E6C0:  59           rolx   
  E6C1:  bfce         stx    g_scratch
  E6C3:  ce0235       ldx    $0235
  E6C6:  8c           clrh   
  E6C7:  cdfe2a       jsr    $FE2A
  E6CA:  a012         sub    #$12
  E6CC:  b6ce         lda    g_scratch
  E6CE:  a200         sbc    #$00
  E6D0:  240a         bcc    LE6DC
  E6D2:  c60234       lda    $0234
  E6D5:  a4fe         and    #$FE
  E6D7:  c70234       sta    $0234
  E6DA:  95           tsx    
  E6DB:  7f           clr    ,x
LE6DC:
  E6DC:  cde649       jsr    $E649
  E6DF:  95           tsx    
  E6E0:  f6           lda    ,x
  E6E1:  a702         ais    #$02
  E6E3:  81           rts    

;---------------------------------------------------------------
; sub_E6E4   [0xE6E4]   <- E30C, E4D1
;---------------------------------------------------------------
  E6E4:  a7fd         ais    #$FD
  E6E6:  cde649       jsr    $E649
  E6E9:  5f           clrx   
  E6EA:  a60a         lda    #$0A
  E6EC:  cde246       jsr    Adc_Read
  E6EF:  95           tsx    
  E6F0:  e702         sta    2,x
  E6F2:  5f           clrx   
  E6F3:  a6f0         lda    #$F0
  E6F5:  cdf497       jsr    Delay_Loop
  E6F8:  5f           clrx   
  E6F9:  a602         lda    #$02
  E6FB:  cde246       jsr    Adc_Read
  E6FE:  95           tsx    
  E6FF:  e701         sta    1,x
  E701:  c60234       lda    $0234
  E704:  a4fe         and    #$FE
  E706:  c70234       sta    $0234
  E709:  a601         lda    #$01
  E70B:  f7           sta    ,x
  E70C:  6d01         tst    1,x
  E70E:  2714         beq    LE724
  E710:  e602         lda    2,x
  E712:  ee01         ldx    1,x
  E714:  8c           clrh   
  E715:  52           div    
  E716:  a105         cmp    #$05
  E718:  240a         bcc    LE724
  E71A:  c60234       lda    $0234
  E71D:  aa04         ora    #$04
  E71F:  c70234       sta    $0234
  E722:  95           tsx    
  E723:  7f           clr    ,x
LE724:
  E724:  95           tsx    
  E725:  f6           lda    ,x
  E726:  a703         ais    #$03
  E728:  81           rts    

;---------------------------------------------------------------
; sub_E729   [0xE729]   <- E591
;---------------------------------------------------------------
  E729:  87           psha   
  E72A:  95           tsx    
  E72B:  7f           clr    ,x
  E72C:  5f           clrx   
  E72D:  a602         lda    #$02
  E72F:  cde246       jsr    Adc_Read
  E732:  c70236       sta    $0236
  E735:  5f           clrx   
  E736:  a61e         lda    #$1E
  E738:  cdf497       jsr    Delay_Loop
  E73B:  5f           clrx   
  E73C:  a602         lda    #$02
  E73E:  cde246       jsr    Adc_Read
  E741:  c70107       sta    $0107
  E744:  450106       ldhx   #$0106
  E747:  89           pshx   
  E748:  8b           pshh   
  E749:  a601         lda    #$01
  E74B:  87           psha   
  E74C:  4f           clra   
  E74D:  87           psha   
  E74E:  c60236       lda    $0236
  E751:  5f           clrx   
  E752:  87           psha   
  E753:  89           pshx   
  E754:  c60107       lda    $0107
  E757:  cdf4ab       jsr    $F4AB
  E75A:  a706         ais    #$06
  E75C:  c70236       sta    $0236
  E75F:  5f           clrx   
  E760:  a61e         lda    #$1E
  E762:  cdf497       jsr    Delay_Loop
  E765:  5f           clrx   
  E766:  a602         lda    #$02
  E768:  cde246       jsr    Adc_Read
  E76B:  c70107       sta    $0107
  E76E:  450106       ldhx   #$0106
  E771:  89           pshx   
  E772:  8b           pshh   
  E773:  a601         lda    #$01
  E775:  87           psha   
  E776:  4f           clra   
  E777:  87           psha   
  E778:  c60236       lda    $0236
  E77B:  5f           clrx   
  E77C:  87           psha   
  E77D:  89           pshx   
  E77E:  c60107       lda    $0107
  E781:  cdf4ab       jsr    $F4AB
  E784:  a706         ais    #$06
  E786:  c70236       sta    $0236
  E789:  8a           pulh   
  E78A:  81           rts    

;---------------------------------------------------------------
; sub_E78B   [0xE78B]   <- C56E
;---------------------------------------------------------------
  E78B:  4f           clra   
  E78C:  c7026e       sta    $026E
  E78F:  5f           clrx   
  E790:  4c           inca   
  E791:  ad38         bsr    LE7CB
  E793:  ccf464       jmp    $F464

;---------------------------------------------------------------
; sub_E796   [0xE796]   <- C680
;---------------------------------------------------------------
  E796:  87           psha   
  E797:  c602aa       lda    $02AA
  E79A:  417e25       cbeqa  #$7E, LE7C2
  E79D:  c6023c       lda    $023C
  E7A0:  4b20         dbnza  LE7C2
  E7A2:  c602aa       lda    $02AA
  E7A5:  a165         cmp    #$65
  E7A7:  2502         bcs    LE7AB
  E7A9:  a650         lda    #$50
LE7AB:
  E7AB:  c7026e       sta    $026E
  E7AE:  2716         beq    LE7C6
  E7B0:  cdf41a       jsr    $F41A
  E7B3:  95           tsx    
  E7B4:  f7           sta    ,x
  E7B5:  2612         bne    LE7C9
  E7B7:  cdf3f1       jsr    $F3F1
  E7BA:  cde27d       jsr    $E27D
  E7BD:  cdf428       jsr    $F428
  E7C0:  2007         bra    LE7C9
LE7C2:
  E7C2:  4f           clra   
  E7C3:  c7026e       sta    $026E
LE7C6:
  E7C6:  cdf464       jsr    $F464
LE7C9:
  E7C9:  8a           pulh   
  E7CA:  81           rts    

;---------------------------------------------------------------
; sub_E7CB   [0xE7CB]   <- C5C1, E791
;---------------------------------------------------------------
  E7CB:  c7023c       sta    $023C
  E7CE:  81           rts    

;---------------------------------------------------------------
; sub_E7CF   [0xE7CF]   <- C57A
;---------------------------------------------------------------
  E7CF:  87           psha   
  E7D0:  95           tsx    
  E7D1:  7f           clr    ,x
  E7D2:  8c           clrh   
  E7D3:  4f           clra   
  E7D4:  9eee01       ldx    1,s
LE7D7:
  E7D7:  d70241       sta    $0241,x
  E7DA:  5c           incx   
  E7DB:  a304         cpx    #$04
  E7DD:  25f8         bcs    LE7D7
  E7DF:  9eef01       stx    1,s
  E7E2:  a604         lda    #$04
  E7E4:  95           tsx    
  E7E5:  f7           sta    ,x
  E7E6:  8c           clrh   
  E7E7:  4f           clra   
  E7E8:  9eee01       ldx    1,s
LE7EB:
  E7EB:  d70241       sta    $0241,x
  E7EE:  5c           incx   
  E7EF:  a310         cpx    #$10
  E7F1:  25f8         bcs    LE7EB
  E7F3:  c7023d       sta    $023D
  E7F6:  8a           pulh   
  E7F7:  81           rts    

;---------------------------------------------------------------
; sub_E7F8   [0xE7F8]   <- C657, EAC5
;---------------------------------------------------------------
  E7F8:  87           psha   
  E7F9:  4f           clra   
  E7FA:  95           tsx    
  E7FB:  f7           sta    ,x
LE7FC:
  E7FC:  5f           clrx   
  E7FD:  ad15         bsr    LE814
  E7FF:  95           tsx    
  E800:  7c           inc    ,x
  E801:  f6           lda    ,x
  E802:  a104         cmp    #$04
  E804:  25f6         bcs    LE7FC
  E806:  4f           clra   
  E807:  f7           sta    ,x
LE808:
  E808:  5f           clrx   
  E809:  ad7e         bsr    LE889
  E80B:  95           tsx    
  E80C:  7c           inc    ,x
  E80D:  f6           lda    ,x
  E80E:  a10c         cmp    #$0C
  E810:  25f6         bcs    LE808
  E812:  8a           pulh   
  E813:  81           rts    

;---------------------------------------------------------------
; sub_E814   [0xE814]   <- E7FD
;---------------------------------------------------------------
  E814:  87           psha   
  E815:  89           pshx   
  E816:  a7fd         ais    #$FD
  E818:  8c           clrh   
  E819:  97           tax    
  E81A:  d60241       lda    $0241,x
  E81D:  48           lsla   
  E81E:  9ee703       sta    3,s
  E821:  9eee05       ldx    5,s
  E824:  58           lslx   
  E825:  58           lslx   
  E826:  d6ff26       lda    $FF26,x
  E829:  9ee702       sta    2,s
  E82C:  deff25       ldx    $FF25,x
  E82F:  f6           lda    ,x
  E830:  9ee701       sta    1,s
  E833:  9eee05       ldx    5,s
  E836:  58           lslx   
  E837:  58           lslx   
  E838:  d6ff26       lda    $FF26,x
  E83B:  9ee401       and    1,s
  E83E:  9ee102       cmp    2,s
  E841:  2703         beq    LE846
  E843:  9e6c03       inc    3,s
LE846:
  E846:  9ee603       lda    3,s
  E849:  a40f         and    #$0F
  E84B:  9ee703       sta    3,s
  E84E:  2609         bne    LE859
  E850:  9eee05       ldx    5,s
  E853:  d70241       sta    $0241,x
  E856:  5f           clrx   
  E857:  200f         bra    LE868
LE859:
  E859:  a10f         cmp    #$0F
  E85B:  261b         bne    LE878
  E85D:  9eee05       ldx    5,s
  E860:  a61f         lda    #$1F
  E862:  d70241       sta    $0241,x
  E865:  5f           clrx   
  E866:  a601         lda    #$01
LE868:
  E868:  87           psha   
  E869:  89           pshx   
  E86A:  9eee07       ldx    7,s
  E86D:  58           lslx   
  E86E:  58           lslx   
  E86F:  9ebeff27     ldhx   $FF27,x
  E873:  cdfcd8       jsr    $FCD8
  E876:  200e         bra    LE886
LE878:
  E878:  9eee05       ldx    5,s
  E87B:  d60241       lda    $0241,x
  E87E:  a4f0         and    #$F0
  E880:  9eea03       ora    3,s
  E883:  d70241       sta    $0241,x
LE886:
  E886:  a705         ais    #$05
  E888:  81           rts    

;---------------------------------------------------------------
; sub_E889   [0xE889]   <- E809
;---------------------------------------------------------------
  E889:  87           psha   
  E88A:  89           pshx   
  E88B:  a7fd         ais    #$FD
  E88D:  ab04         add    #$04
  E88F:  95           tsx    
  E890:  e701         sta    1,x
  E892:  97           tax    
  E893:  8c           clrh   
  E894:  d60241       lda    $0241,x
  E897:  48           lsla   
  E898:  9ee701       sta    1,s
  E89B:  9ee605       lda    5,s
  E89E:  ae05         ldx    #$05
  E8A0:  42           mul    
  E8A1:  97           tax    
  E8A2:  d6ff37       lda    $FF37,x
  E8A5:  5f           clrx   
  E8A6:  87           psha   
  E8A7:  89           pshx   
  E8A8:  9ee607       lda    7,s
  E8AB:  ae05         ldx    #$05
  E8AD:  42           mul    
  E8AE:  97           tax    
  E8AF:  d6ff36       lda    $FF36,x
  E8B2:  5f           clrx   
  E8B3:  87           psha   
  E8B4:  89           pshx   
  E8B5:  9ee609       lda    9,s
  E8B8:  ae05         ldx    #$05
  E8BA:  42           mul    
  E8BB:  97           tax    
  E8BC:  d6ff35       lda    $FF35,x
  E8BF:  5f           clrx   
  E8C0:  ad4c         bsr    LE90E
  E8C2:  a704         ais    #$04
  E8C4:  95           tsx    
  E8C5:  e702         sta    2,x
  E8C7:  4b01         dbnza  LE8CA
  E8C9:  7c           inc    ,x
LE8CA:
  E8CA:  f6           lda    ,x
  E8CB:  a40f         and    #$0F
  E8CD:  f7           sta    ,x
  E8CE:  2609         bne    LE8D9
  E8D0:  ee01         ldx    1,x
  E8D2:  8c           clrh   
  E8D3:  d70241       sta    $0241,x
  E8D6:  5f           clrx   
  E8D7:  200f         bra    LE8E8
LE8D9:
  E8D9:  a10f         cmp    #$0F
  E8DB:  261d         bne    LE8FA
  E8DD:  ee01         ldx    1,x
  E8DF:  8c           clrh   
  E8E0:  a61f         lda    #$1F
  E8E2:  d70241       sta    $0241,x
  E8E5:  5f           clrx   
  E8E6:  a601         lda    #$01
LE8E8:
  E8E8:  87           psha   
  E8E9:  89           pshx   
  E8EA:  9ee607       lda    7,s
  E8ED:  ae05         ldx    #$05
  E8EF:  42           mul    
  E8F0:  97           tax    
  E8F1:  9ebeff38     ldhx   $FF38,x
  E8F5:  cdfcd8       jsr    $FCD8
  E8F8:  2011         bra    LE90B
LE8FA:
  E8FA:  ee04         ldx    4,x
  E8FC:  8c           clrh   
  E8FD:  d60241       lda    $0241,x
  E900:  a4f0         and    #$F0
  E902:  9eea01       ora    1,s
  E905:  9eee02       ldx    2,s
  E908:  d70241       sta    $0241,x
LE90B:
  E90B:  a705         ais    #$05
  E90D:  81           rts    

;---------------------------------------------------------------
; sub_E90E   [0xE90E]   <- E8C0
;---------------------------------------------------------------
  E90E:  87           psha   
  E90F:  89           pshx   
  E910:  87           psha   
  E911:  5f           clrx   
  E912:  cde246       jsr    Adc_Read
  E915:  95           tsx    
  E916:  f7           sta    ,x
  E917:  e606         lda    6,x
  E919:  f1           cmp    ,x
  E91A:  2409         bcc    LE925
  E91C:  f6           lda    ,x
  E91D:  e108         cmp    8,x
  E91F:  2404         bcc    LE925
  E921:  a601         lda    #$01
  E923:  2001         bra    LE926
LE925:
  E925:  4f           clra   
LE926:
  E926:  a703         ais    #$03
  E928:  81           rts    
;   .... data/gap E929-EA88 ....

;---------------------------------------------------------------
; sub_EA88   [0xEA88]   <- C577
;---------------------------------------------------------------
  EA88:  4f           clra   
  EA89:  c7025a       sta    $025A
  EA8C:  c7025b       sta    $025B
  EA8F:  c7025c       sta    $025C
  EA92:  c7025d       sta    $025D
  EA95:  c70258       sta    $0258
  EA98:  c7025e       sta    $025E
  EA9B:  c70260       sta    $0260
  EA9E:  c70261       sta    $0261
  EAA1:  c7025f       sta    $025F
  EAA4:  c70259       sta    $0259
  EAA7:  c70255       sta    $0255
  EAAA:  c70256       sta    $0256
  EAAD:  c70253       sta    $0253
  EAB0:  c70254       sta    $0254
  EAB3:  c70251       sta    $0251
  EAB6:  c70252       sta    $0252
  EAB9:  4c           inca   
  EABA:  c70295       sta    $0295
  EABD:  81           rts    

;---------------------------------------------------------------
; sub_EABE   [0xEABE]   <- C58F
;---------------------------------------------------------------
  EABE:  87           psha   
  EABF:  4f           clra   
  EAC0:  c70257       sta    $0257
  EAC3:  95           tsx    
  EAC4:  7f           clr    ,x
LEAC5:
  EAC5:  cde7f8       jsr    $E7F8
  EAC8:  95           tsx    
  EAC9:  7c           inc    ,x
  EACA:  f6           lda    ,x
  EACB:  a105         cmp    #$05
  EACD:  25f6         bcs    LEAC5
  EACF:  7f           clr    ,x
LEAD0:
  EAD0:  95           tsx    
  EAD1:  fe           ldx    ,x
  EAD2:  58           lslx   
  EAD3:  8c           clrh   
  EAD4:  d60274       lda    $0274,x
  EAD7:  4b18         dbnza  LEAF1
  EAD9:  d60273       lda    $0273,x
  EADC:  a107         cmp    #$07
  EADE:  2604         bne    LEAE4
  EAE0:  a609         lda    #$09
  EAE2:  200a         bra    LEAEE
LEAE4:
  EAE4:  a104         cmp    #$04
  EAE6:  2604         bne    LEAEC
  EAE8:  a606         lda    #$06
  EAEA:  2002         bra    LEAEE
LEAEC:
  EAEC:  a603         lda    #$03
LEAEE:
  EAEE:  d70273       sta    $0273,x
LEAF1:
  EAF1:  95           tsx    
  EAF2:  7c           inc    ,x
  EAF3:  fe           ldx    ,x
  EAF4:  a308         cpx    #$08
  EAF6:  25d8         bcs    LEAD0
  EAF8:  c60271       lda    $0271
  EAFB:  a101         cmp    #$01
  EAFD:  2603         bne    LEB02
  EAFF:  c70257       sta    $0257
LEB02:
  EB02:  c60272       lda    $0272
  EB05:  a101         cmp    #$01
  EB07:  2603         bne    LEB0C
  EB09:  c70257       sta    $0257
LEB0C:
  EB0C:  8a           pulh   
  EB0D:  81           rts    
;   .... data/gap EB0E-EC3A ....
LEC3A:
  EC3A:  c6025b       lda    $025B
  EC3D:  2704         beq    LEC43
  EC3F:  45025b       ldhx   #$025B
  EC42:  7a           dec    ,x
LEC43:
  EC43:  c6025f       lda    $025F
  EC46:  2704         beq    LEC4C
  EC48:  45025f       ldhx   #$025F
  EC4B:  7a           dec    ,x
LEC4C:
  EC4C:  32025c       ldhx   $025C
  EC4F:  270a         beq    LEC5B
  EC51:  65ffff       cphx   #$FFFF
  EC54:  2405         bcc    LEC5B
  EC56:  af01         aix    #$01
  EC58:  96025c       sthx   $025C
LEC5B:
  EC5B:  320260       ldhx   $0260
  EC5E:  270a         beq    LEC6A
  EC60:  65ffff       cphx   #$FFFF
  EC63:  2405         bcc    LEC6A
  EC65:  af01         aix    #$01
  EC67:  960260       sthx   $0260
LEC6A:
  EC6A:  320251       ldhx   $0251
  EC6D:  270a         beq    LEC79
  EC6F:  65ffff       cphx   #$FFFF
  EC72:  2405         bcc    LEC79
  EC74:  af01         aix    #$01
  EC76:  960251       sthx   $0251
LEC79:
  EC79:  320253       ldhx   $0253
  EC7C:  270a         beq    LEC88
  EC7E:  65ffff       cphx   #$FFFF
  EC81:  2405         bcc    LEC88
  EC83:  af01         aix    #$01
  EC85:  960253       sthx   $0253
LEC88:
  EC88:  320255       ldhx   $0255
  EC8B:  270a         beq    LEC97
  EC8D:  65ffff       cphx   #$FFFF
  EC90:  2405         bcc    LEC97
  EC92:  af01         aix    #$01
  EC94:  960255       sthx   $0255
LEC97:
  EC97:  81           rts    
;   .... data/gap EC98-F28E ....

;---------------------------------------------------------------
; Ports_Init   [0xF28E]   <- C559
;---------------------------------------------------------------
  F28E:  a601         lda    #$01
  F290:  c70262       sta    $0262
  F293:  a61c         lda    #$1C
  F295:  c71809       sta    SPMSC1
  F298:  a601         lda    #$01
  F29A:  c7180a       sta    SPMSC2
  F29D:  4f           clra   
  F29E:  c70000       sta    PTAD
  F2A1:  4a           deca   
  F2A2:  c70001       sta    PTADD
  F2A5:  c71841       sta    PTASE
  F2A8:  4f           clra   
  F2A9:  c71842       sta    PTADS
  F2AC:  c70002       sta    PTBD
  F2AF:  4a           deca   
  F2B0:  c70003       sta    PTBDD
  F2B3:  c71845       sta    PTBSE
  F2B6:  4f           clra   
  F2B7:  c71846       sta    PTBDS
  F2BA:  450004       ldhx   #$0004
  F2BD:  f6           lda    ,x
  F2BE:  aa01         ora    #$01
  F2C0:  f7           sta    ,x
  F2C1:  a6ff         lda    #$FF
  F2C3:  c70005       sta    PTCDD
  F2C6:  450005       ldhx   #$0005
  F2C9:  f6           lda    ,x
  F2CA:  a4d1         and    #$D1
  F2CC:  f7           sta    ,x
  F2CD:  f6           lda    ,x
  F2CE:  aa01         ora    #$01
  F2D0:  f7           sta    ,x
  F2D1:  4f           clra   
  F2D2:  c71848       sta    PTCPE
  F2D5:  c71849       sta    PTCSE
  F2D8:  c7184a       sta    PTCDS
  F2DB:  c70006       sta    PTDD
  F2DE:  4a           deca   
  F2DF:  c70007       sta    PTDDD
  F2E2:  450007       ldhx   #$0007
  F2E5:  f6           lda    ,x
  F2E6:  a4f0         and    #$F0
  F2E8:  f7           sta    ,x
  F2E9:  4f           clra   
  F2EA:  c7184c       sta    PTDPE
  F2ED:  c7184d       sta    PTDSE
  F2F0:  c7184e       sta    PTDDS
  F2F3:  450008       ldhx   #$0008
  F2F6:  f6           lda    ,x
  F2F7:  aa81         ora    #$81
  F2F9:  f7           sta    ,x
  F2FA:  a6fd         lda    #$FD
  F2FC:  c70009       sta    PTEDD
  F2FF:  4f           clra   
  F300:  c71850       sta    PTEPE
  F303:  c71851       sta    PTESE
  F306:  c71852       sta    PTEDS
  F309:  c7000a       sta    PTFD
  F30C:  a6df         lda    #$DF
  F30E:  c7000b       sta    PTFDD
  F311:  45000b       ldhx   #$000B
  F314:  f6           lda    ,x
  F315:  a4df         and    #$DF
  F317:  f7           sta    ,x
  F318:  4f           clra   
  F319:  c71854       sta    PTFPE
  F31C:  c71855       sta    PTFSE
  F31F:  c71856       sta    PTFDS
  F322:  c7000c       sta    PTGD
  F325:  4a           deca   
  F326:  c7000d       sta    PTGDD
  F329:  45000d       ldhx   #$000D
  F32C:  f6           lda    ,x
  F32D:  a4f0         and    #$F0
  F32F:  f7           sta    ,x
  F330:  4f           clra   
  F331:  c71858       sta    PTGPE
  F334:  c71859       sta    PTGSE
  F337:  c7185a       sta    PTGDS
  F33A:  81           rts    

;---------------------------------------------------------------
; sub_F33B   [0xF33B]   <- C69C
;---------------------------------------------------------------
  F33B:  450001       ldhx   #$0001
  F33E:  f6           lda    ,x
  F33F:  aa01         ora    #$01
  F341:  f7           sta    ,x
  F342:  450003       ldhx   #$0003
  F345:  f6           lda    ,x
  F346:  a4fb         and    #$FB
  F348:  f7           sta    ,x
  F349:  450005       ldhx   #$0005
  F34C:  f6           lda    ,x
  F34D:  a4d1         and    #$D1
  F34F:  f7           sta    ,x
  F350:  f6           lda    ,x
  F351:  aa01         ora    #$01
  F353:  f7           sta    ,x
  F354:  450007       ldhx   #$0007
  F357:  f6           lda    ,x
  F358:  a4f0         and    #$F0
  F35A:  f7           sta    ,x
  F35B:  450009       ldhx   #$0009
  F35E:  f6           lda    ,x
  F35F:  aa84         ora    #$84
  F361:  f7           sta    ,x
  F362:  45000b       ldhx   #$000B
  F365:  f6           lda    ,x
  F366:  aa11         ora    #$11
  F368:  f7           sta    ,x
  F369:  f6           lda    ,x
  F36A:  a4df         and    #$DF
  F36C:  f7           sta    ,x
  F36D:  45000d       ldhx   #$000D
  F370:  f6           lda    ,x
  F371:  a4f0         and    #$F0
  F373:  f7           sta    ,x
  F374:  81           rts    

;---------------------------------------------------------------
; sub_F375   [0xF375]   <- C704
;---------------------------------------------------------------
  F375:  450008       ldhx   #$0008
  F378:  f6           lda    ,x
  F379:  a47f         and    #$7F
  F37B:  f7           sta    ,x
  F37C:  81           rts    

;---------------------------------------------------------------
; sub_F37D   [0xF37D]   <- C713, C734
;---------------------------------------------------------------
  F37D:  450008       ldhx   #$0008
  F380:  f6           lda    ,x
  F381:  aa80         ora    #$80
  F383:  f7           sta    ,x
  F384:  81           rts    

;---------------------------------------------------------------
; sub_F385   [0xF385]   <- C6C1
;---------------------------------------------------------------
  F385:  450004       ldhx   #$0004
  F388:  f6           lda    ,x
  F389:  a4fe         and    #$FE
  F38B:  f7           sta    ,x
  F38C:  450008       ldhx   #$0008
  F38F:  f6           lda    ,x
  F390:  a4fe         and    #$FE
  F392:  f7           sta    ,x
  F393:  450009       ldhx   #$0009
  F396:  f6           lda    ,x
  F397:  aa01         ora    #$01
  F399:  f7           sta    ,x
  F39A:  81           rts    

;---------------------------------------------------------------
; sub_F39B   [0xF39B]   <- C6C4
;---------------------------------------------------------------
  F39B:  4f           clra   
  F39C:  c70001       sta    PTADD
  F39F:  c70003       sta    PTBDD
  F3A2:  a681         lda    #$81
  F3A4:  c70005       sta    PTCDD
  F3A7:  4f           clra   
  F3A8:  c70007       sta    PTDDD
  F3AB:  4c           inca   
  F3AC:  c70009       sta    PTEDD
  F3AF:  4f           clra   
  F3B0:  c7000b       sta    PTFDD
  F3B3:  c7000d       sta    PTGDD
  F3B6:  81           rts    

;---------------------------------------------------------------
; sub_F3B7   [0xF3B7]
;---------------------------------------------------------------
  F3B7:  8b           pshh   
  F3B8:  a7fb         ais    #$FB
  F3BA:  32026c       ldhx   $026C
  F3BD:  9eff01       sthx   1,s
  F3C0:  a6c8         lda    #$C8
  F3C2:  95           tsx    
  F3C3:  e702         sta    2,x
  F3C5:  4f           clra   
  F3C6:  c0002d       sub    TPM1C2VL
  F3C9:  e703         sta    3,x
  F3CB:  e602         lda    2,x
  F3CD:  c2002c       sbc    TPM1C2VH
  F3D0:  e702         sta    2,x
  F3D2:  c60265       lda    $0265
  F3D5:  4b0f         dbnza  LF3E6
  F3D7:  4f           clra   
  F3D8:  e001         sub    1,x
  F3DA:  87           psha   
  F3DB:  a6c8         lda    #$C8
  F3DD:  f2           sbc    ,x
  F3DE:  97           tax    
  F3DF:  86           pula   
  F3E0:  cf002c       stx    TPM1C2VH
  F3E3:  c7002d       sta    TPM1C2VL
LF3E6:
  F3E6:  450020       ldhx   #$0020
  F3E9:  f6           lda    ,x
  F3EA:  a47f         and    #$7F
  F3EC:  f7           sta    ,x
  F3ED:  a705         ais    #$05
  F3EF:  8a           pulh   
  F3F0:  80           rti    

;---------------------------------------------------------------
; sub_F3F1   [0xF3F1]   <- C574, E7B7
;---------------------------------------------------------------
  F3F1:  ad71         bsr    LF464
  F3F3:  4f           clra   
  F3F4:  c70263       sta    $0263
  F3F7:  81           rts    

;---------------------------------------------------------------
; sub_F3F8   [0xF3F8]   <- C6AD
;---------------------------------------------------------------
  F3F8:  c60263       lda    $0263
  F3FB:  2715         beq    LF412
  F3FD:  ad65         bsr    LF464
  F3FF:  45000a       ldhx   #$000A
  F402:  f6           lda    ,x
  F403:  aa01         ora    #$01
  F405:  f7           sta    ,x
  F406:  5f           clrx   
  F407:  a664         lda    #$64
  F409:  cdf497       jsr    Delay_Loop
  F40C:  4f           clra   
  F40D:  c70263       sta    $0263
  F410:  ad16         bsr    LF428
LF412:
  F412:  45000a       ldhx   #$000A
  F415:  f6           lda    ,x
  F416:  a4fe         and    #$FE
  F418:  f7           sta    ,x
  F419:  81           rts    

;---------------------------------------------------------------
; sub_F41A   [0xF41A]   <- E7B0
;---------------------------------------------------------------
  F41A:  87           psha   
  F41B:  95           tsx    
  F41C:  7f           clr    ,x
  F41D:  c6002b       lda    TPM1C2SC
  F420:  a420         and    #$20
  F422:  2702         beq    LF426
  F424:  a601         lda    #$01
LF426:
  F426:  8a           pulh   
  F427:  81           rts    

;---------------------------------------------------------------
; sub_F428   [0xF428]   <- E7BD, F410
;---------------------------------------------------------------
  F428:  a7fe         ais    #$FE
  F42A:  c60020       lda    TPM1SC
  F42D:  c701a6       sta    $01A6
  F430:  4f           clra   
  F431:  c70020       sta    TPM1SC
  F434:  c60263       lda    $0263
  F437:  2622         bne    LF45B
  F439:  c70265       sta    $0265
  F43C:  45000a       ldhx   #$000A
  F43F:  f6           lda    ,x
  F440:  a4fe         and    #$FE
  F442:  f7           sta    ,x
  F443:  a6c8         lda    #$C8
  F445:  c7002c       sta    TPM1C2VH
  F448:  4f           clra   
  F449:  c7002d       sta    TPM1C2VL
  F44C:  a624         lda    #$24
  F44E:  c7002b       sta    TPM1C2SC
  F451:  a655         lda    #$55
  F453:  c70022       sta    TPM1CNTL
  F456:  a601         lda    #$01
  F458:  c70265       sta    $0265
LF45B:
  F45B:  c601a6       lda    $01A6
  F45E:  c70020       sta    TPM1SC
  F461:  a702         ais    #$02
  F463:  81           rts    

;---------------------------------------------------------------
; sub_F464   [0xF464]   <- E7C6, F3F1, F3FD
;---------------------------------------------------------------
  F464:  45000a       ldhx   #$000A
  F467:  f6           lda    ,x
  F468:  a4fe         and    #$FE
  F46A:  f7           sta    ,x
  F46B:  4f           clra   
  F46C:  c7002b       sta    TPM1C2SC
  F46F:  f6           lda    ,x
  F470:  a4fe         and    #$FE
  F472:  f7           sta    ,x
  F473:  a6c8         lda    #$C8
  F475:  c7002c       sta    TPM1C2VH
  F478:  4f           clra   
  F479:  c7002d       sta    TPM1C2VL
  F47C:  81           rts    
;   .... data/gap F47D-F497 ....

;---------------------------------------------------------------
; Delay_Loop   [0xF497]   <- E257, E437, E485, E69B, E6F5, E738, E762, F409
;---------------------------------------------------------------
  F497:  450000       ldhx   #$0000
  F49A:  97           tax    
LF49B:
  F49B:  afff         aix    #$FF
  F49D:  650000       cphx   #$0000
  F4A0:  21f9         brn    LF49B
  F4A2:  21f7         brn    LF49B
  F4A4:  21f5         brn    LF49B
  F4A6:  21f3         brn    LF49B
  F4A8:  26f1         bne    LF49B
  F4AA:  81           rts    

;---------------------------------------------------------------
; sub_F4AB   [0xF4AB]   <- E757, E781, F668, F836, F88F
;---------------------------------------------------------------
  F4AB:  87           psha   
  F4AC:  89           pshx   
  F4AD:  a7fb         ais    #$FB
  F4AF:  95           tsx    
  F4B0:  6d0c         tst    12,x
  F4B2:  2606         bne    LF4BA
  F4B4:  9ece0d       ldhx   13,x
  F4B7:  7f           clr    ,x
  F4B8:  200b         bra    LF4C5
LF4BA:
  F4BA:  e10a         cmp    10,x
  F4BC:  260a         bne    LF4C8
  F4BE:  9ece0d       ldhx   13,x
  F4C1:  7f           clr    ,x
  F4C2:  95           tsx    
  F4C3:  e606         lda    6,x
LF4C5:
  F4C5:  a707         ais    #$07
  F4C7:  81           rts    
LF4C8:
  F4C8:  e60a         lda    10,x
  F4CA:  e701         sta    1,x
  F4CC:  7f           clr    ,x
  F4CD:  e606         lda    6,x
  F4CF:  e001         sub    1,x
  F4D1:  e703         sta    3,x
  F4D3:  4f           clra   
  F4D4:  f2           sbc    ,x
  F4D5:  e702         sta    2,x
  F4D7:  e603         lda    3,x
  F4D9:  e704         sta    4,x
  F4DB:  e10c         cmp    12,x
  F4DD:  2514         bcs    LF4F3
  F4DF:  ee02         ldx    2,x
  F4E1:  bfce         stx    g_scratch
  F4E3:  9eee0d       ldx    13,s
  F4E6:  8c           clrh   
  F4E7:  cdfd08       jsr    $FD08
  F4EA:  95           tsx    
  F4EB:  e703         sta    3,x
  F4ED:  b6ce         lda    g_scratch
  F4EF:  e702         sta    2,x
  F4F1:  2036         bra    LF529
LF4F3:
  F4F3:  e60c         lda    12,x
  F4F5:  3fce         clr    g_scratch
  F4F7:  ee04         ldx    4,x
  F4F9:  8c           clrh   
  F4FA:  cdfd08       jsr    $FD08
  F4FD:  9efe0e       ldhx   14,s
  F500:  87           psha   
  F501:  f6           lda    ,x
  F502:  95           tsx    
  F503:  f0           sub    ,x
  F504:  4f           clra   
  F505:  b2ce         sbc    g_scratch
  F507:  86           pula   
  F508:  900a         bge    LF514
  F50A:  6f03         clr    3,x
  F50C:  6f04         clr    4,x
  F50E:  9ece0e       ldhx   14,x
  F511:  7c           inc    ,x
  F512:  2019         bra    LF52D
LF514:
  F514:  95           tsx    
  F515:  e606         lda    6,x
  F517:  e10a         cmp    10,x
  F519:  2505         bcs    LF520
  F51B:  5f           clrx   
  F51C:  a601         lda    #$01
  F51E:  2003         bra    LF523
LF520:
  F520:  a6ff         lda    #$FF
  F522:  97           tax    
LF523:
  F523:  9ee704       sta    4,s
  F526:  9eef03       stx    3,s
LF529:
  F529:  9efe0e       ldhx   14,s
  F52C:  7f           clr    ,x
LF52D:
  F52D:  95           tsx    
  F52E:  e603         lda    3,x
  F530:  eb0a         add    10,x
  F532:  a707         ais    #$07
  F534:  81           rts    

;---------------------------------------------------------------
; sub_F535   [0xF535]   <- F676
;---------------------------------------------------------------
  F535:  87           psha   
  F536:  89           pshx   
  F537:  a7fb         ais    #$FB
  F539:  9efe0a       ldhx   10,s
  F53C:  f6           lda    ,x
  F53D:  95           tsx    
  F53E:  e106         cmp    6,x
  F540:  2503         bcs    LF545
  F542:  ccf5d9       jmp    $F5D9
LF545:
  F545:  7f           clr    ,x
LF546:
  F546:  9efe0a       ldhx   10,s
  F549:  f6           lda    ,x
  F54A:  e102         cmp    2,x
  F54C:  2407         bcc    LF555
  F54E:  af02         aix    #$02
  F550:  9eff0a       sthx   10,s
  F553:  2007         bra    LF55C
LF555:
  F555:  a601         lda    #$01
  F557:  95           tsx    
  F558:  f7           sta    ,x
  F559:  9ece09       ldhx   9,x
LF55C:
  F55C:  f6           lda    ,x
  F55D:  95           tsx    
  F55E:  e106         cmp    6,x
  F560:  2403         bcc    LF565
  F562:  7d           tst    ,x
  F563:  27e1         beq    LF546
LF565:
  F565:  7d           tst    ,x
  F566:  2671         bne    LF5D9
  F568:  9ece09       ldhx   9,x
  F56B:  e601         lda    1,x
  F56D:  d0ffff       sub    $FFFF,x
  F570:  250e         bcs    LF580
  F572:  d6ffff       lda    $FFFF,x
  F575:  e001         sub    1,x
  F577:  40           nega   
  F578:  95           tsx    
  F579:  e703         sta    3,x
  F57B:  a601         lda    #$01
  F57D:  f7           sta    ,x
  F57E:  2005         bra    LF585
LF580:
  F580:  40           nega   
  F581:  95           tsx    
  F582:  e703         sta    3,x
  F584:  7f           clr    ,x
LF585:
  F585:  9efe0a       ldhx   10,s
  F588:  d6fffe       lda    $FFFE,x
  F58B:  f0           sub    ,x
  F58C:  40           nega   
  F58D:  95           tsx    
  F58E:  e704         sta    4,x
  F590:  e606         lda    6,x
  F592:  3fce         clr    g_scratch
  F594:  9ece09       ldhx   9,x
  F597:  d0fffe       sub    $FFFE,x
  F59A:  2402         bcc    LF59E
  F59C:  3ace         dec    g_scratch
LF59E:
  F59E:  95           tsx    
  F59F:  ee03         ldx    3,x
  F5A1:  8c           clrh   
  F5A2:  cdfd5b       jsr    $FD5B
  F5A5:  9eee05       ldx    5,s
  F5A8:  8c           clrh   
  F5A9:  cdfe2a       jsr    $FE2A
  F5AC:  95           tsx    
  F5AD:  e702         sta    2,x
  F5AF:  b6ce         lda    g_scratch
  F5B1:  e701         sta    1,x
  F5B3:  f6           lda    ,x
  F5B4:  9ece09       ldhx   9,x
  F5B7:  4b0f         dbnza  LF5C8
  F5B9:  9ee603       lda    3,s
  F5BC:  dbffff       add    $FFFF,x
  F5BF:  95           tsx    
  F5C0:  e702         sta    2,x
  F5C2:  241f         bcc    LF5E3
  F5C4:  6c01         inc    1,x
  F5C6:  201b         bra    LF5E3
LF5C8:
  F5C8:  d6ffff       lda    $FFFF,x
  F5CB:  95           tsx    
  F5CC:  e002         sub    2,x
  F5CE:  e702         sta    2,x
  F5D0:  4f           clra   
  F5D1:  e201         sbc    1,x
  F5D3:  e701         sta    1,x
  F5D5:  e602         lda    2,x
  F5D7:  200a         bra    LF5E3
LF5D9:
  F5D9:  9efe0a       ldhx   10,s
  F5DC:  e601         lda    1,x
  F5DE:  95           tsx    
  F5DF:  e702         sta    2,x
  F5E1:  6f01         clr    1,x
LF5E3:
  F5E3:  a707         ais    #$07
  F5E5:  81           rts    

;---------------------------------------------------------------
; EnterCritical   [0xF5E6]   <- App_InitAll, C5E0, C636, C707, C8EC, C90C, CC5B, FC3A
;---------------------------------------------------------------
  F5E6:  9b           sei    
  F5E7:  c60109       lda    $0109
  F5EA:  a17e         cmp    #$7E
  F5EC:  2404         bcc    LF5F2
  F5EE:  450109       ldhx   #$0109
  F5F1:  7c           inc    ,x
LF5F2:
  F5F2:  81           rts    

;---------------------------------------------------------------
; ExitCritical   [0xF5F3]   <- C5F4, C640, C72F, C8F2, C953, CC79, FCD2
;---------------------------------------------------------------
  F5F3:  c60109       lda    $0109
  F5F6:  2708         beq    LF600
  F5F8:  a17f         cmp    #$7F
  F5FA:  2404         bcc    LF600
  F5FC:  450109       ldhx   #$0109
  F5FF:  7a           dec    ,x
LF600:
  F600:  c60109       lda    $0109
  F603:  2601         bne    LF606
  F605:  9a           cli    
LF606:
  F606:  81           rts    

;---------------------------------------------------------------
; sub_F607   [0xF607]   <- C589
;---------------------------------------------------------------
  F607:  c6019c       lda    $019C
  F60A:  a406         and    #$06
  F60C:  41020e       cbeqa  #$02, LF61D
  F60F:  c6019c       lda    $019C
  F612:  a406         and    #$06
  F614:  410606       cbeqa  #$06, LF61D
  F617:  a6ff         lda    #$FF
  F619:  c702a0       sta    $02A0
  F61C:  81           rts    
LF61D:
  F61D:  a6fe         lda    #$FE
  F61F:  c702a0       sta    $02A0
  F622:  a606         lda    #$06
  F624:  c70264       sta    $0264
  F627:  81           rts    

;---------------------------------------------------------------
; sub_F628   [0xF628]   <- C688, C6A1
;---------------------------------------------------------------
  F628:  87           psha   
  F629:  c6019c       lda    $019C
  F62C:  a406         and    #$06
  F62E:  41020c       cbeqa  #$02, LF63D
  F631:  c6019c       lda    $019C
  F634:  a406         and    #$06
  F636:  410604       cbeqa  #$06, LF63D
  F639:  a6ff         lda    #$FF
  F63B:  204e         bra    LF68B
LF63D:
  F63D:  5f           clrx   
  F63E:  a603         lda    #$03
  F640:  cde246       jsr    Adc_Read
  F643:  95           tsx    
  F644:  f7           sta    ,x
  F645:  a1f8         cmp    #$F8
  F647:  2504         bcs    LF64D
  F649:  a6fd         lda    #$FD
  F64B:  202e         bra    LF67B
LF64D:
  F64D:  a115         cmp    #$15
  F64F:  2404         bcc    LF655
  F651:  a6ff         lda    #$FF
  F653:  2026         bra    LF67B
LF655:
  F655:  45010b       ldhx   #$010B
  F658:  89           pshx   
  F659:  8b           pshh   
  F65A:  a604         lda    #$04
  F65C:  87           psha   
  F65D:  4f           clra   
  F65E:  87           psha   
  F65F:  c6010a       lda    $010A
  F662:  5f           clrx   
  F663:  87           psha   
  F664:  89           pshx   
  F665:  9ee607       lda    7,s
  F668:  cdf4ab       jsr    $F4AB
  F66B:  a706         ais    #$06
  F66D:  c7010a       sta    $010A
  F670:  450164       ldhx   #$0164
  F673:  89           pshx   
  F674:  8b           pshh   
  F675:  5f           clrx   
  F676:  cdf535       jsr    $F535
  F679:  a702         ais    #$02
LF67B:
  F67B:  95           tsx    
  F67C:  f7           sta    ,x
  F67D:  c60264       lda    $0264
  F680:  2708         beq    LF68A
  F682:  450264       ldhx   #$0264
  F685:  7a           dec    ,x
  F686:  a6fe         lda    #$FE
  F688:  2001         bra    LF68B
LF68A:
  F68A:  f6           lda    ,x
LF68B:
  F68B:  c702a0       sta    $02A0
  F68E:  8a           pulh   
  F68F:  81           rts    

;---------------------------------------------------------------
; Inputs_Init   [0xF690]   <- C55F
;---------------------------------------------------------------
  F690:  87           psha   
  F691:  95           tsx    
  F692:  7f           clr    ,x
  F693:  8c           clrh   
  F694:  4f           clra   
  F695:  9eee01       ldx    1,s
LF698:
  F698:  d70297       sta    $0297,x
  F69B:  5c           incx   
  F69C:  a31d         cpx    #$1D
  F69E:  25f8         bcs    LF698
  F6A0:  9eef01       stx    1,s
  F6A3:  95           tsx    
  F6A4:  7f           clr    ,x
  F6A5:  8c           clrh   
  F6A6:  9eee01       ldx    1,s
LF6A9:
  F6A9:  58           lslx   
  F6AA:  a60f         lda    #$0F
  F6AC:  d70273       sta    $0273,x
  F6AF:  4f           clra   
  F6B0:  d70274       sta    $0274,x
  F6B3:  9e6c01       inc    1,s
  F6B6:  9eee01       ldx    1,s
  F6B9:  a308         cpx    #$08
  F6BB:  25ec         bcs    LF6A9
  F6BD:  c6019c       lda    $019C
  F6C0:  a406         and    #$06
  F6C2:  a102         cmp    #$02
  F6C4:  2604         bne    LF6CA
  F6C6:  a604         lda    #$04
  F6C8:  2009         bra    LF6D3
LF6CA:
  F6CA:  c6019c       lda    $019C
  F6CD:  a404         and    #$04
  F6CF:  2705         beq    LF6D6
  F6D1:  a607         lda    #$07
LF6D3:
  F6D3:  c70275       sta    $0275
LF6D6:
  F6D6:  a60f         lda    #$0F
  F6D8:  c70283       sta    $0283
  F6DB:  4f           clra   
  F6DC:  c70284       sta    $0284
  F6DF:  a60f         lda    #$0F
  F6E1:  c70285       sta    $0285
  F6E4:  4f           clra   
  F6E5:  c70286       sta    $0286
  F6E8:  c70296       sta    $0296
  F6EB:  c70294       sta    $0294
  F6EE:  c70293       sta    $0293
  F6F1:  c70291       sta    $0291
  F6F4:  c70290       sta    $0290
  F6F7:  c7028e       sta    $028E
  F6FA:  c7028d       sta    $028D
  F6FD:  c7028c       sta    $028C
  F700:  c7028b       sta    $028B
  F703:  a6f0         lda    #$F0
  F705:  c7028a       sta    $028A
  F708:  4f           clra   
  F709:  c70289       sta    $0289
  F70C:  c70288       sta    $0288
  F70F:  c70272       sta    $0272
  F712:  c70271       sta    $0271
  F715:  c70270       sta    $0270
  F718:  c7026f       sta    $026F
  F71B:  c7026a       sta    $026A
  F71E:  c70295       sta    $0295
  F721:  c7026e       sta    $026E
  F724:  c7026c       sta    $026C
  F727:  c7026d       sta    $026D
  F72A:  c7026b       sta    $026B
  F72D:  c70268       sta    $0268
  F730:  c70269       sta    $0269
  F733:  c70267       sta    $0267
  F736:  4c           inca   
  F737:  c70266       sta    $0266
  F73A:  c70265       sta    $0265
  F73D:  8a           pulh   
  F73E:  81           rts    

;---------------------------------------------------------------
; sub_F73F   [0xF73F]   <- C580, F877
;---------------------------------------------------------------
  F73F:  a7fd         ais    #$FD
  F741:  a601         lda    #$01
  F743:  c702b4       sta    $02B4
  F746:  450000       ldhx   #$0000
  F749:  f6           lda    ,x
  F74A:  aa01         ora    #$01
  F74C:  f7           sta    ,x
  F74D:  c60199       lda    $0199
  F750:  2704         beq    LF756
  F752:  a140         cmp    #$40
  F754:  2502         bcs    LF758
LF756:
  F756:  a619         lda    #$19
LF758:
  F758:  c702ba       sta    $02BA
  F75B:  c60198       lda    $0198
  F75E:  a147         cmp    #$47
  F760:  2508         bcs    LF76A
  F762:  a1c8         cmp    #$C8
  F764:  2404         bcc    LF76A
  F766:  a023         sub    #$23
  F768:  2002         bra    LF76C
LF76A:
  F76A:  a623         lda    #$23
LF76C:
  F76C:  c702bb       sta    $02BB
  F76F:  97           tax    
  F770:  8c           clrh   
  F771:  af41         aix    #$41
  F773:  9f           txa    
  F774:  8b           pshh   
  F775:  88           pulx   
  F776:  cdf497       jsr    Delay_Loop
  F779:  4f           clra   
  F77A:  95           tsx    
  F77B:  e702         sta    2,x
  F77D:  8c           clrh   
LF77E:
  F77E:  ae03         ldx    #$03
  F780:  42           mul    
  F781:  97           tax    
  F782:  4f           clra   
  F783:  d702bc       sta    $02BC,x
  F786:  9ee603       lda    3,s
  F789:  ae03         ldx    #$03
  F78B:  42           mul    
  F78C:  87           psha   
  F78D:  8b           pshh   
  F78E:  9ee605       lda    5,s
  F791:  ae06         ldx    #$06
  F793:  42           mul    
  F794:  97           tax    
  F795:  d6ff73       lda    $FF73,x
  F798:  9ee704       sta    4,s
  F79B:  9ebeff71     ldhx   $FF71,x
  F79F:  f6           lda    ,x
  F7A0:  95           tsx    
  F7A1:  e702         sta    2,x
  F7A3:  e604         lda    4,x
  F7A5:  ae06         ldx    #$06
  F7A7:  42           mul    
  F7A8:  8c           clrh   
  F7A9:  97           tax    
  F7AA:  d6ff73       lda    $FF73,x
  F7AD:  95           tsx    
  F7AE:  e402         and    2,x
  F7B0:  e403         and    3,x
  F7B2:  8a           pulh   
  F7B3:  88           pulx   
  F7B4:  d702bd       sta    $02BD,x
  F7B7:  95           tsx    
  F7B8:  e602         lda    2,x
  F7BA:  ae03         ldx    #$03
  F7BC:  42           mul    
  F7BD:  8c           clrh   
  F7BE:  87           psha   
  F7BF:  8b           pshh   
  F7C0:  9ee605       lda    5,s
  F7C3:  ae06         ldx    #$06
  F7C5:  42           mul    
  F7C6:  97           tax    
  F7C7:  d6ff76       lda    $FF76,x
  F7CA:  9ee704       sta    4,s
  F7CD:  9ebeff74     ldhx   $FF74,x
  F7D1:  f6           lda    ,x
  F7D2:  95           tsx    
  F7D3:  e702         sta    2,x
  F7D5:  e604         lda    4,x
  F7D7:  ae06         ldx    #$06
  F7D9:  42           mul    
  F7DA:  8c           clrh   
  F7DB:  97           tax    
  F7DC:  d6ff76       lda    $FF76,x
  F7DF:  95           tsx    
  F7E0:  e402         and    2,x
  F7E2:  e403         and    3,x
  F7E4:  8a           pulh   
  F7E5:  88           pulx   
  F7E6:  d702be       sta    $02BE,x
  F7E9:  9eee03       ldx    3,s
  F7EC:  8c           clrh   
  F7ED:  a602         lda    #$02
  F7EF:  d702b6       sta    $02B6,x
  F7F2:  9e6c03       inc    3,s
  F7F5:  9ee603       lda    3,s
  F7F8:  a102         cmp    #$02
  F7FA:  2582         bcs    LF77E
  F7FC:  450000       ldhx   #$0000
  F7FF:  f6           lda    ,x
  F800:  a4fe         and    #$FE
  F802:  f7           sta    ,x
  F803:  4f           clra   
  F804:  c702b5       sta    $02B5
  F807:  a703         ais    #$03
  F809:  81           rts    

;---------------------------------------------------------------
; sub_F80A   [0xF80A]   <- Task_2Ticks
;---------------------------------------------------------------
  F80A:  87           psha   
  F80B:  450000       ldhx   #$0000
  F80E:  f6           lda    ,x
  F80F:  aa01         ora    #$01
  F811:  f7           sta    ,x
  F812:  5f           clrx   
  F813:  a60a         lda    #$0A
  F815:  cde246       jsr    Adc_Read
  F818:  95           tsx    
  F819:  f7           sta    ,x
  F81A:  a14e         cmp    #$4E
  F81C:  255e         bcs    LF87C
  F81E:  c602b4       lda    $02B4
  F821:  4b54         dbnza  LF877
  F823:  4502b5       ldhx   #$02B5
  F826:  89           pshx   
  F827:  8b           pshh   
  F828:  a602         lda    #$02
  F82A:  87           psha   
  F82B:  4f           clra   
  F82C:  87           psha   
  F82D:  c60267       lda    $0267
  F830:  5f           clrx   
  F831:  87           psha   
  F832:  89           pshx   
  F833:  9ee607       lda    7,s
  F836:  cdf4ab       jsr    $F4AB
  F839:  a706         ais    #$06
  F83B:  c70267       sta    $0267
  F83E:  cde27d       jsr    $E27D
  F841:  c602bb       lda    $02BB
  F844:  5f           clrx   
  F845:  cdf497       jsr    Delay_Loop
  F848:  a602         lda    #$02
  F84A:  95           tsx    
  F84B:  f7           sta    ,x
  F84C:  8c           clrh   
LF84D:
  F84D:  9eee01       ldx    1,s
  F850:  afff         aix    #$FF
  F852:  9f           txa    
  F853:  8b           pshh   
  F854:  88           pulx   
  F855:  ad50         bsr    LF8A7
  F857:  95           tsx    
  F858:  f6           lda    ,x
  F859:  48           lsla   
  F85A:  a002         sub    #$02
  F85C:  8c           clrh   
  F85D:  87           psha   
  F85E:  9ee602       lda    2,s
  F861:  ae03         ldx    #$03
  F863:  42           mul    
  F864:  a003         sub    #$03
  F866:  97           tax    
  F867:  d602bc       lda    $02BC,x
  F86A:  88           pulx   
  F86B:  db0284       add    $0284,x
  F86E:  d70284       sta    $0284,x
  F871:  9e6b01d8     dbnz   1,s, LF84D
  F875:  2027         bra    LF89E
LF877:
  F877:  cdf73f       jsr    $F73F
  F87A:  2022         bra    LF89E
LF87C:
  F87C:  4502b5       ldhx   #$02B5
  F87F:  89           pshx   
  F880:  8b           pshh   
  F881:  a602         lda    #$02
  F883:  87           psha   
  F884:  4f           clra   
  F885:  87           psha   
  F886:  c60267       lda    $0267
  F889:  5f           clrx   
  F88A:  87           psha   
  F88B:  89           pshx   
  F88C:  9ee607       lda    7,s
  F88F:  cdf4ab       jsr    $F4AB
  F892:  a706         ais    #$06
  F894:  c70267       sta    $0267
  F897:  cde27d       jsr    $E27D
  F89A:  4f           clra   
  F89B:  c702b4       sta    $02B4
LF89E:
  F89E:  450000       ldhx   #$0000
  F8A1:  f6           lda    ,x
  F8A2:  a4fe         and    #$FE
  F8A4:  f7           sta    ,x
  F8A5:  8a           pulh   
  F8A6:  81           rts    

;---------------------------------------------------------------
; sub_F8A7   [0xF8A7]   <- F855
;---------------------------------------------------------------
  F8A7:  87           psha   
  F8A8:  89           pshx   
  F8A9:  a7fb         ais    #$FB
  F8AB:  95           tsx    
  F8AC:  6f03         clr    3,x
  F8AE:  6f04         clr    4,x
  F8B0:  97           tax    
  F8B1:  8c           clrh   
  F8B2:  4f           clra   
  F8B3:  d702b8       sta    $02B8,x
  F8B6:  9ee607       lda    7,s
  F8B9:  ae06         ldx    #$06
  F8BB:  42           mul    
  F8BC:  97           tax    
  F8BD:  9ebeff71     ldhx   $FF71,x
  F8C1:  f6           lda    ,x
  F8C2:  95           tsx    
  F8C3:  f7           sta    ,x
  F8C4:  e606         lda    6,x
  F8C6:  ae06         ldx    #$06
  F8C8:  42           mul    
  F8C9:  8c           clrh   
  F8CA:  97           tax    
  F8CB:  d6ff73       lda    $FF73,x
  F8CE:  9ee401       and    1,s
  F8D1:  9ee702       sta    2,s
  F8D4:  9ebeff74     ldhx   $FF74,x
  F8D8:  f6           lda    ,x
  F8D9:  95           tsx    
  F8DA:  f7           sta    ,x
  F8DB:  e606         lda    6,x
  F8DD:  ae06         ldx    #$06
  F8DF:  42           mul    
  F8E0:  8c           clrh   
  F8E1:  97           tax    
  F8E2:  d6ff76       lda    $FF76,x
  F8E5:  95           tsx    
  F8E6:  f4           and    ,x
  F8E7:  e702         sta    2,x
  F8E9:  c602ba       lda    $02BA
  F8EC:  5f           clrx   
  F8ED:  cdf497       jsr    Delay_Loop
  F8F0:  95           tsx    
  F8F1:  e606         lda    6,x
  F8F3:  ae06         ldx    #$06
  F8F5:  42           mul    
  F8F6:  8c           clrh   
  F8F7:  97           tax    
  F8F8:  9ebeff71     ldhx   $FF71,x
  F8FC:  f6           lda    ,x
  F8FD:  95           tsx    
  F8FE:  f7           sta    ,x
  F8FF:  e606         lda    6,x
  F901:  ae06         ldx    #$06
  F903:  42           mul    
  F904:  8c           clrh   
  F905:  97           tax    
  F906:  d6ff73       lda    $FF73,x
  F909:  9ee401       and    1,s
  F90C:  9ee102       cmp    2,s
  F90F:  261e         bne    LF92F
  F911:  9ebeff74     ldhx   $FF74,x
  F915:  f6           lda    ,x
  F916:  95           tsx    
  F917:  f7           sta    ,x
  F918:  e606         lda    6,x
  F91A:  ae06         ldx    #$06
  F91C:  42           mul    
  F91D:  8c           clrh   
  F91E:  97           tax    
  F91F:  d6ff76       lda    $FF76,x
  F922:  9ee401       and    1,s
  F925:  9ee103       cmp    3,s
  F928:  2605         bne    LF92F
  F92A:  a601         lda    #$01
  F92C:  9ee705       sta    5,s
LF92F:
  F92F:  9ee607       lda    7,s
  F932:  ae03         ldx    #$03
  F934:  42           mul    
  F935:  97           tax    
  F936:  d602bd       lda    $02BD,x
  F939:  9ee102       cmp    2,s
  F93C:  270b         beq    LF949
  F93E:  d602be       lda    $02BE,x
  F941:  9ee103       cmp    3,s
  F944:  2703         beq    LF949
LF946:
  F946:  ccfa21       jmp    $FA21
LF949:
  F949:  9ee605       lda    5,s
  F94C:  4a           deca   
  F94D:  26f7         bne    LF946
  F94F:  d602bd       lda    $02BD,x
  F952:  9ee102       cmp    2,s
  F955:  273c         beq    LF993
  F957:  9ee607       lda    7,s
  F95A:  ae06         ldx    #$06
  F95C:  42           mul    
  F95D:  97           tax    
  F95E:  d6ff76       lda    $FF76,x
  F961:  9ee103       cmp    3,s
  F964:  2617         bne    LF97D
  F966:  d6ff73       lda    $FF73,x
  F969:  9ee102       cmp    2,s
  F96C:  2717         beq    LF985
LF96E:
  F96E:  9eee07       ldx    7,s
  F971:  d602b8       lda    $02B8,x
  F974:  2666         bne    LF9DC
  F976:  a601         lda    #$01
  F978:  d702b6       sta    $02B6,x
  F97B:  204d         bra    LF9CA
LF97D:
  F97D:  d6ff73       lda    $FF73,x
  F980:  9ee102       cmp    2,s
  F983:  27e9         beq    LF96E
LF985:
  F985:  9eee07       ldx    7,s
  F988:  d602b6       lda    $02B6,x
  F98B:  a102         cmp    #$02
  F98D:  264d         bne    LF9DC
  F98F:  a6ff         lda    #$FF
  F991:  2046         bra    LF9D9
LF993:
  F993:  d602be       lda    $02BE,x
  F996:  9ee103       cmp    3,s
  F999:  2741         beq    LF9DC
  F99B:  9ee607       lda    7,s
  F99E:  ae06         ldx    #$06
  F9A0:  42           mul    
  F9A1:  97           tax    
  F9A2:  d6ff73       lda    $FF73,x
  F9A5:  9ee102       cmp    2,s
  F9A8:  260a         bne    LF9B4
  F9AA:  d6ff76       lda    $FF76,x
  F9AD:  9ee103       cmp    3,s
  F9B0:  260a         bne    LF9BC
  F9B2:  201b         bra    LF9CF
LF9B4:
  F9B4:  d6ff76       lda    $FF76,x
  F9B7:  9ee103       cmp    3,s
  F9BA:  2613         bne    LF9CF
LF9BC:
  F9BC:  9eee07       ldx    7,s
  F9BF:  d602b8       lda    $02B8,x
  F9C2:  2618         bne    LF9DC
  F9C4:  a602         lda    #$02
  F9C6:  d702b6       sta    $02B6,x
  F9C9:  4a           deca   
LF9CA:
  F9CA:  d702b8       sta    $02B8,x
  F9CD:  200d         bra    LF9DC
LF9CF:
  F9CF:  9eee07       ldx    7,s
  F9D2:  d602b6       lda    $02B6,x
  F9D5:  a101         cmp    #$01
  F9D7:  2603         bne    LF9DC
LF9D9:
  F9D9:  95           tsx    
  F9DA:  e703         sta    3,x
LF9DC:
  F9DC:  95           tsx    
  F9DD:  e606         lda    6,x
  F9DF:  ae03         ldx    #$03
  F9E1:  42           mul    
  F9E2:  8c           clrh   
  F9E3:  97           tax    
  F9E4:  9ee604       lda    4,s
  F9E7:  d702bc       sta    $02BC,x
  F9EA:  9ee607       lda    7,s
  F9ED:  ae03         ldx    #$03
  F9EF:  42           mul    
  F9F0:  87           psha   
  F9F1:  8b           pshh   
  F9F2:  9ee609       lda    9,s
  F9F5:  ae06         ldx    #$06
  F9F7:  42           mul    
  F9F8:  97           tax    
  F9F9:  d6ff76       lda    $FF76,x
  F9FC:  95           tsx    
  F9FD:  e404         and    4,x
  F9FF:  8a           pulh   
  FA00:  88           pulx   
  FA01:  d702be       sta    $02BE,x
  FA04:  95           tsx    
  FA05:  e606         lda    6,x
  FA07:  ae03         ldx    #$03
  FA09:  42           mul    
  FA0A:  8c           clrh   
  FA0B:  87           psha   
  FA0C:  8b           pshh   
  FA0D:  9ee609       lda    9,s
  FA10:  ae06         ldx    #$06
  FA12:  42           mul    
  FA13:  97           tax    
  FA14:  d6ff73       lda    $FF73,x
  FA17:  95           tsx    
  FA18:  e403         and    3,x
  FA1A:  8a           pulh   
  FA1B:  88           pulx   
  FA1C:  d702bd       sta    $02BD,x
  FA1F:  2047         bra    LFA68
LFA21:
  FA21:  9ee605       lda    5,s
  FA24:  4b37         dbnza  LFA5D
  FA26:  9ee607       lda    7,s
  FA29:  ae03         ldx    #$03
  FA2B:  42           mul    
  FA2C:  8c           clrh   
  FA2D:  87           psha   
  FA2E:  8b           pshh   
  FA2F:  9ee609       lda    9,s
  FA32:  ae06         ldx    #$06
  FA34:  42           mul    
  FA35:  97           tax    
  FA36:  d6ff76       lda    $FF76,x
  FA39:  95           tsx    
  FA3A:  e404         and    4,x
  FA3C:  8a           pulh   
  FA3D:  88           pulx   
  FA3E:  d702be       sta    $02BE,x
  FA41:  95           tsx    
  FA42:  e606         lda    6,x
  FA44:  ae03         ldx    #$03
  FA46:  42           mul    
  FA47:  8c           clrh   
  FA48:  87           psha   
  FA49:  8b           pshh   
  FA4A:  9ee609       lda    9,s
  FA4D:  ae06         ldx    #$06
  FA4F:  42           mul    
  FA50:  97           tax    
  FA51:  d6ff73       lda    $FF73,x
  FA54:  95           tsx    
  FA55:  e403         and    3,x
  FA57:  8a           pulh   
  FA58:  88           pulx   
  FA59:  d702bd       sta    $02BD,x
  FA5C:  8c           clrh   
LFA5D:
  FA5D:  9ee607       lda    7,s
  FA60:  ae03         ldx    #$03
  FA62:  42           mul    
  FA63:  97           tax    
  FA64:  4f           clra   
  FA65:  d702bc       sta    $02BC,x
LFA68:
  FA68:  a707         ais    #$07
  FA6A:  81           rts    

;---------------------------------------------------------------
; sub_FA6B   [0xFA6B]   <- C56B
;---------------------------------------------------------------
  FA6B:  c61800       lda    SRS
  FA6E:  c7010c       sta    $010C
  FA71:  a480         and    #$80
  FA73:  265e         bne    LFAD3
  FA75:  c6010c       lda    $010C
  FA78:  a440         and    #$40
  FA7A:  2710         beq    LFA8C
  FA7C:  c60193       lda    $0193
  FA7F:  a1fe         cmp    #$FE
  FA81:  2409         bcc    LFA8C
  FA83:  450193       ldhx   #$0193
  FA86:  7c           inc    ,x
  FA87:  a601         lda    #$01
  FA89:  c7026a       sta    $026A
LFA8C:
  FA8C:  c6010c       lda    $010C
  FA8F:  a460         and    #$60
  FA91:  a120         cmp    #$20
  FA93:  2610         bne    LFAA5
  FA95:  c60194       lda    $0194
  FA98:  a1fe         cmp    #$FE
  FA9A:  2409         bcc    LFAA5
  FA9C:  450194       ldhx   #$0194
  FA9F:  7c           inc    ,x
  FAA0:  a601         lda    #$01
  FAA2:  c7026a       sta    $026A
LFAA5:
  FAA5:  c6010c       lda    $010C
  FAA8:  a410         and    #$10
  FAAA:  2710         beq    LFABC
  FAAC:  c60195       lda    $0195
  FAAF:  a1fe         cmp    #$FE
  FAB1:  2409         bcc    LFABC
  FAB3:  450195       ldhx   #$0195
  FAB6:  7c           inc    ,x
  FAB7:  a601         lda    #$01
  FAB9:  c7026a       sta    $026A
LFABC:
  FABC:  c6010c       lda    $010C
  FABF:  a404         and    #$04
  FAC1:  2710         beq    LFAD3
  FAC3:  c60196       lda    $0196
  FAC6:  a1fe         cmp    #$FE
  FAC8:  2409         bcc    LFAD3
  FACA:  450196       ldhx   #$0196
  FACD:  7c           inc    ,x
  FACE:  a601         lda    #$01
  FAD0:  c7026a       sta    $026A
LFAD3:
  FAD3:  81           rts    

;---------------------------------------------------------------
; sub_FAD4   [0xFAD4]   <- C683, C6A4
;---------------------------------------------------------------
  FAD4:  ad13         bsr    LFAE9
  FAD6:  cdfb9e       jsr    $FB9E
  FAD9:  c6026b       lda    $026B
  FADC:  410804       cbeqa  #$08, LFAE3
  FADF:  a110         cmp    #$10
  FAE1:  2605         bne    LFAE8
LFAE3:
  FAE3:  a601         lda    #$01
  FAE5:  c702a8       sta    $02A8
LFAE8:
  FAE8:  81           rts    

;---------------------------------------------------------------
; sub_FAE9   [0xFAE9]   <- FAD4
;---------------------------------------------------------------
  FAE9:  a7fc         ais    #$FC
  FAEB:  32010d       ldhx   $010D
  FAEE:  6501dd       cphx   #$01DD
  FAF1:  2470         bcc    LFB63
  FAF3:  c6010e       lda    $010E
  FAF6:  ce010d       ldx    $010D
  FAF9:  48           lsla   
  FAFA:  59           rolx   
  FAFB:  48           lsla   
  FAFC:  59           rolx   
  FAFD:  48           lsla   
  FAFE:  59           rolx   
  FAFF:  48           lsla   
  FB00:  59           rolx   
  FB01:  48           lsla   
  FB02:  59           rolx   
  FB03:  9ee702       sta    2,s
  FB06:  9f           txa    
  FB07:  abc4         add    #$C4
  FB09:  95           tsx    
  FB0A:  f7           sta    ,x
  FB0B:  2028         bra    LFB35
LFB0D:
  FB0D:  9efe01       ldhx   1,s
  FB10:  9eae         ldhx   ,x
  FB12:  9eff03       sthx   3,s
  FB15:  9f           txa    
  FB16:  c80111       eor    $0111
  FB19:  c70111       sta    $0111
  FB1C:  c60110       lda    $0110
  FB1F:  95           tsx    
  FB20:  e802         eor    2,x
  FB22:  c70110       sta    $0110
  FB25:  9ece02       ldhx   2,x
  FB28:  af01         aix    #$01
  FB2A:  9eff03       sthx   3,s
  FB2D:  9efe01       ldhx   1,s
  FB30:  af02         aix    #$02
  FB32:  9eff01       sthx   1,s
LFB35:
  FB35:  c6010e       lda    $010E
  FB38:  ce010d       ldx    $010D
  FB3B:  48           lsla   
  FB3C:  59           rolx   
  FB3D:  48           lsla   
  FB3E:  59           rolx   
  FB3F:  48           lsla   
  FB40:  59           rolx   
  FB41:  48           lsla   
  FB42:  59           rolx   
  FB43:  48           lsla   
  FB44:  59           rolx   
  FB45:  ab20         add    #$20
  FB47:  87           psha   
  FB48:  9f           txa    
  FB49:  a9c4         adc    #$C4
  FB4B:  97           tax    
  FB4C:  86           pula   
  FB4D:  99           sec    
  FB4E:  9ee202       sbc    2,s
  FB51:  9f           txa    
  FB52:  95           tsx    
  FB53:  f2           sbc    ,x
  FB54:  24b7         bcc    LFB0D
  FB56:  32010d       ldhx   $010D
  FB59:  af01         aix    #$01
  FB5B:  96010d       sthx   $010D
  FB5E:  c6010f       lda    $010F
  FB61:  2005         bra    LFB68
LFB63:
  FB63:  a601         lda    #$01
  FB65:  c7010f       sta    $010F
LFB68:
  FB68:  4b31         dbnza  LFB9B
  FB6A:  320110       ldhx   $0110
  FB6D:  960268       sthx   $0268
  FB70:  ce019d       ldx    $019D
  FB73:  4f           clra   
  FB74:  cb019e       add    $019E
  FB77:  2401         bcc    LFB7A
  FB79:  5c           incx   
LFB7A:
  FB7A:  c10269       cmp    $0269
  FB7D:  2605         bne    LFB84
  FB7F:  c30268       cpx    $0268
  FB82:  2707         beq    LFB8B
LFB84:
  FB84:  45026b       ldhx   #$026B
  FB87:  f6           lda    ,x
  FB88:  aa10         ora    #$10
  FB8A:  f7           sta    ,x
LFB8B:
  FB8B:  4f           clra   
  FB8C:  c7010f       sta    $010F
  FB8F:  c70110       sta    $0110
  FB92:  c70111       sta    $0111
  FB95:  c7010d       sta    $010D
  FB98:  c7010e       sta    $010E
LFB9B:
  FB9B:  a704         ais    #$04
  FB9D:  81           rts    

;---------------------------------------------------------------
; sub_FB9E   [0xFB9E]   <- FAD6
;---------------------------------------------------------------
  FB9E:  a7fd         ais    #$FD
  FBA0:  95           tsx    
  FBA1:  6f02         clr    2,x
  FBA3:  c60112       lda    $0112
  FBA6:  a501         bit    #$01
  FBA8:  2703         beq    LFBAD
  FBAA:  ccfc3a       jmp    $FC3A
LFBAD:
  FBAD:  c60114       lda    $0114
  FBB0:  ce0113       ldx    $0113
  FBB3:  48           lsla   
  FBB4:  59           rolx   
  FBB5:  48           lsla   
  FBB6:  59           rolx   
  FBB7:  ab70         add    #$70
  FBB9:  2401         bcc    LFBBC
  FBBB:  5c           incx   
LFBBC:
  FBBC:  9ee702       sta    2,s
  FBBF:  9eef01       stx    1,s
  FBC2:  2028         bra    LFBEC
LFBC4:
  FBC4:  a6aa         lda    #$AA
  FBC6:  f7           sta    ,x
  FBC7:  95           tsx    
  FBC8:  6c02         inc    2,x
  FBCA:  9eae         ldhx   ,x
  FBCC:  f6           lda    ,x
  FBCD:  a1aa         cmp    #$AA
  FBCF:  260c         bne    LFBDD
  FBD1:  a655         lda    #$55
  FBD3:  f7           sta    ,x
  FBD4:  95           tsx    
  FBD5:  6c02         inc    2,x
  FBD7:  9eae         ldhx   ,x
  FBD9:  f6           lda    ,x
  FBDA:  415507       cbeqa  #$55, LFBE4
LFBDD:
  FBDD:  450112       ldhx   #$0112
  FBE0:  f6           lda    ,x
  FBE1:  aa02         ora    #$02
  FBE3:  f7           sta    ,x
LFBE4:
  FBE4:  9efe01       ldhx   1,s
  FBE7:  af01         aix    #$01
  FBE9:  9eff01       sthx   1,s
LFBEC:
  FBEC:  c60114       lda    $0114
  FBEF:  ce0113       ldx    $0113
  FBF2:  48           lsla   
  FBF3:  59           rolx   
  FBF4:  48           lsla   
  FBF5:  59           rolx   
  FBF6:  ab74         add    #$74
  FBF8:  2401         bcc    LFBFB
  FBFA:  5c           incx   
LFBFB:
  FBFB:  99           sec    
  FBFC:  9ee202       sbc    2,s
  FBFF:  9f           txa    
  FC00:  95           tsx    
  FC01:  f2           sbc    ,x
  FC02:  2507         bcs    LFC0B
  FC04:  9eae         ldhx   ,x
  FC06:  65007a       cphx   #$007A
  FC09:  25b9         bcs    LFBC4
LFC0B:
  FC0B:  9efe01       ldhx   1,s
  FC0E:  650079       cphx   #$0079
  FC11:  450112       ldhx   #$0112
  FC14:  f6           lda    ,x
  FC15:  2504         bcs    LFC1B
  FC17:  aa01         ora    #$01
  FC19:  2002         bra    LFC1D
LFC1B:
  FC1B:  a4fe         and    #$FE
LFC1D:
  FC1D:  f7           sta    ,x
  FC1E:  c60112       lda    $0112
  FC21:  a401         and    #$01
  FC23:  270a         beq    LFC2F
  FC25:  4f           clra   
  FC26:  c70113       sta    $0113
  FC29:  c70114       sta    $0114
  FC2C:  ccfcd5       jmp    $FCD5
LFC2F:
  FC2F:  320113       ldhx   $0113
  FC32:  af01         aix    #$01
  FC34:  960113       sthx   $0113
  FC37:  ccfcd5       jmp    $FCD5
LFC3A:
  FC3A:  cdf5e6       jsr    EnterCritical
  FC3D:  c60114       lda    $0114
  FC40:  ce0113       ldx    $0113
  FC43:  48           lsla   
  FC44:  59           rolx   
  FC45:  48           lsla   
  FC46:  59           rolx   
  FC47:  ab7a         add    #$7A
  FC49:  2401         bcc    LFC4C
  FC4B:  5c           incx   
LFC4C:
  FC4C:  c70073       sta    $0073
  FC4F:  cf0072       stx    $0072
  FC52:  320072       ldhx   $0072
  FC55:  af03         aix    #$03
  FC57:  960070       sthx   $0070
  FC5A:  320072       ldhx   $0072
  FC5D:  960074       sthx   $0074
  FC60:  2739         beq    LFC9B
  FC62:  202f         bra    LFC93
LFC64:
  FC64:  f6           lda    ,x
  FC65:  c70076       sta    $0076
  FC68:  a6aa         lda    #$AA
  FC6A:  f7           sta    ,x
  FC6B:  95           tsx    
  FC6C:  6c02         inc    2,x
  FC6E:  320074       ldhx   $0074
  FC71:  f6           lda    ,x
  FC72:  a1aa         cmp    #$AA
  FC74:  260d         bne    LFC83
  FC76:  a655         lda    #$55
  FC78:  f7           sta    ,x
  FC79:  95           tsx    
  FC7A:  6c02         inc    2,x
  FC7C:  320074       ldhx   $0074
  FC7F:  f6           lda    ,x
  FC80:  41550a       cbeqa  #$55, LFC8D
LFC83:
  FC83:  450112       ldhx   #$0112
  FC86:  f6           lda    ,x
  FC87:  aa02         ora    #$02
  FC89:  f7           sta    ,x
  FC8A:  320074       ldhx   $0074
LFC8D:
  FC8D:  c60076       lda    $0076
  FC90:  f7           sta    ,x
  FC91:  af01         aix    #$01
LFC93:
  FC93:  960074       sthx   $0074
  FC96:  3e0070       cphx   $0070
  FC99:  23c9         bls    LFC64
LFC9B:
  FC9B:  6501f6       cphx   #$01F6
  FC9E:  262a         bne    LFCCA
  FCA0:  4f           clra   
  FCA1:  c70113       sta    $0113
  FCA4:  c70114       sta    $0114
  FCA7:  450112       ldhx   #$0112
  FCAA:  f6           lda    ,x
  FCAB:  a4fe         and    #$FE
  FCAD:  f7           sta    ,x
  FCAE:  a402         and    #$02
  FCB0:  2708         beq    LFCBA
  FCB2:  45026b       ldhx   #$026B
  FCB5:  f6           lda    ,x
  FCB6:  aa08         ora    #$08
  FCB8:  2006         bra    LFCC0
LFCBA:
  FCBA:  45026b       ldhx   #$026B
  FCBD:  f6           lda    ,x
  FCBE:  a4f7         and    #$F7
LFCC0:
  FCC0:  f7           sta    ,x
  FCC1:  450112       ldhx   #$0112
  FCC4:  f6           lda    ,x
  FCC5:  a4fd         and    #$FD
  FCC7:  f7           sta    ,x
  FCC8:  2008         bra    LFCD2
LFCCA:
  FCCA:  320113       ldhx   $0113
  FCCD:  af01         aix    #$01
  FCCF:  960113       sthx   $0113
LFCD2:
  FCD2:  cdf5f3       jsr    ExitCritical
LFCD5:
  FCD5:  a703         ais    #$03
  FCD7:  81           rts    

;---------------------------------------------------------------
; sub_FCD8   [0xFCD8]   <- DCA6, E873, E8F5
;---------------------------------------------------------------
  FCD8:  9ee603       lda    3,s
  FCDB:  87           psha   
  FCDC:  9ee602       lda    2,s
  FCDF:  9ee704       sta    4,s
  FCE2:  9ee605       lda    5,s
  FCE5:  9ee702       sta    2,s
  FCE8:  9ee603       lda    3,s
  FCEB:  9ee705       sta    5,s
  FCEE:  9eef03       stx    3,s
  FCF1:  88           pulx   
  FCF2:  86           pula   
  FCF3:  8b           pshh   
  FCF4:  81           rts    
;   .... data/gap FCF5-FCFC ....

;---------------------------------------------------------------
; u8_mod   [0xFCFC]   <- C60E, C622
;---------------------------------------------------------------
  FCFC:  89           pshx   
  FCFD:  ae80         ldx    #$80
  FCFF:  2009         bra    LFD0A
;   .... data/gap FD01-FD08 ....

;---------------------------------------------------------------
; sub_FD08   [0xFD08]   <- E2A1, F4E7, F4FA
;---------------------------------------------------------------
  FD08:  89           pshx   
  FD09:  5f           clrx   
LFD0A:
  FD0A:  3dce         tst    g_scratch
  FD0C:  2a09         bpl    LFD17
  FD0E:  5c           incx   
  FD0F:  89           pshx   
  FD10:  bece         ldx    g_scratch
  FD12:  ad41         bsr    LFD55
  FD14:  bfce         stx    g_scratch
  FD16:  88           pulx   
LFD17:
  FD17:  87           psha   
  FD18:  8b           pshh   
  FD19:  9e6d01       tst    1,s
  FD1C:  2a12         bpl    LFD30
  FD1E:  5c           incx   
  FD1F:  5c           incx   
  FD20:  89           pshx   
  FD21:  9ee604       lda    4,s
  FD24:  9eee02       ldx    2,s
  FD27:  ad2c         bsr    LFD55
  FD29:  9ee704       sta    4,s
  FD2C:  9eef02       stx    2,s
  FD2F:  88           pulx   
LFD30:
  FD30:  8a           pulh   
  FD31:  86           pula   
  FD32:  89           pshx   
  FD33:  9eee02       ldx    2,s
  FD36:  cdfe2a       jsr    $FE2A
  FD39:  9e6d01       tst    1,s
  FD3C:  2a09         bpl    LFD47
  FD3E:  86           pula   
  FD3F:  44           lsra   
  FD40:  9f           txa    
  FD41:  8b           pshh   
  FD42:  88           pulx   
  FD43:  240c         bcc    LFD51
  FD45:  2008         bra    LFD4F
LFD47:
  FD47:  88           pulx   
  FD48:  5c           incx   
  FD49:  54           lsrx   
  FD4A:  54           lsrx   
  FD4B:  2406         bcc    LFD53
  FD4D:  bece         ldx    g_scratch
LFD4F:
  FD4F:  ad04         bsr    LFD55
LFD51:
  FD51:  bfce         stx    g_scratch
LFD53:
  FD53:  88           pulx   
  FD54:  81           rts    

;---------------------------------------------------------------
; sub_FD55   [0xFD55]   <- FD12, FD27, FD4F
;---------------------------------------------------------------
  FD55:  53           comx   
  FD56:  40           nega   
  FD57:  2601         bne    LFD5A
  FD59:  5c           incx   
LFD5A:
  FD5A:  81           rts    

;---------------------------------------------------------------
; sub_FD5B   [0xFD5B]   <- E2BB, F5A2
;---------------------------------------------------------------
  FD5B:  89           pshx   
  FD5C:  87           psha   
  FD5D:  b6ce         lda    g_scratch
  FD5F:  42           mul    
  FD60:  b7ce         sta    g_scratch
  FD62:  8b           pshh   
  FD63:  88           pulx   
  FD64:  86           pula   
  FD65:  87           psha   
  FD66:  42           mul    
  FD67:  bbce         add    g_scratch
  FD69:  b7ce         sta    g_scratch
  FD6B:  86           pula   
  FD6C:  88           pulx   
  FD6D:  42           mul    
  FD6E:  87           psha   
  FD6F:  9f           txa    
  FD70:  bbce         add    g_scratch
  FD72:  b7ce         sta    g_scratch
  FD74:  86           pula   
  FD75:  81           rts    
;   .... data/gap FD76-FD89 ....
LFD89:
  FD89:  87           psha   
LFD8A:
  FD8A:  7d           tst    ,x
  FD8B:  2604         bne    LFD91
  FD8D:  6d01         tst    1,x
  FD8F:  2751         beq    LFDE2
LFD91:
  FD91:  9ee601       lda    1,s
  FD94:  e003         sub    3,x
  FD96:  87           psha   
  FD97:  b6ce         lda    g_scratch
  FD99:  e202         sbc    2,x
  FD9B:  2b0d         bmi    LFDAA
  FD9D:  87           psha   
  FD9E:  9ee602       lda    2,s
  FDA1:  e001         sub    1,x
  FDA3:  9ee601       lda    1,s
  FDA6:  f2           sbc    ,x
  FDA7:  2b1c         bmi    LFDC5
  FDA9:  86           pula   
LFDAA:
  FDAA:  86           pula   
  FDAB:  8b           pshh   
  FDAC:  9f           txa    
  FDAD:  eb01         add    1,x
  FDAF:  2403         bcc    LFDB4
  FDB1:  9e6c01       inc    1,s
LFDB4:
  FDB4:  eb01         add    1,x
  FDB6:  87           psha   
  FDB7:  f6           lda    ,x
  FDB8:  49           rola   
  FDB9:  88           pulx   
  FDBA:  9eeb01       add    1,s
  FDBD:  9ee701       sta    1,s
  FDC0:  8a           pulh   
  FDC1:  af04         aix    #$04
  FDC3:  20c5         bra    LFD8A
LFDC5:
  FDC5:  9e6802       lsl    2,s
  FDC8:  9e6901       rol    1,s
  FDCB:  9f           txa    
  FDCC:  9eeb02       add    2,s
  FDCF:  97           tax    
  FDD0:  86           pula   
  FDD1:  8b           pshh   
  FDD2:  9ee901       adc    1,s
  FDD5:  9ee701       sta    1,s
  FDD8:  8a           pulh   
LFDD9:
  FDD9:  a702         ais    #$02
  FDDB:  e605         lda    5,x
  FDDD:  87           psha   
  FDDE:  e604         lda    4,x
  FDE0:  87           psha   
  FDE1:  81           rts    
LFDE2:
  FDE2:  e603         lda    3,x
  FDE4:  87           psha   
  FDE5:  27f2         beq    LFDD9
LFDE7:
  FDE7:  e606         lda    6,x
  FDE9:  b1ce         cmp    g_scratch
  FDEB:  2607         bne    LFDF4
  FDED:  e607         lda    7,x
  FDEF:  9ee102       cmp    2,s
  FDF2:  27e5         beq    LFDD9
LFDF4:
  FDF4:  af04         aix    #$04
  FDF6:  9e6b01ed     dbnz   1,s, LFDE7
  FDFA:  20dd         bra    LFDD9

;---------------------------------------------------------------
; sub_FDFC   [0xFDFC]   <- E2CC
;---------------------------------------------------------------
  FDFC:  87           psha   
  FDFD:  b6ca         lda    $CA
  FDFF:  f1           cmp    ,x
  FE00:  261e         bne    LFE20
  FE02:  b6cb         lda    $CB
  FE04:  e101         cmp    1,x
  FE06:  260c         bne    LFE14
  FE08:  b6cc         lda    $CC
  FE0A:  e102         cmp    2,x
  FE0C:  2606         bne    LFE14
  FE0E:  b6cd         lda    $CD
  FE10:  e103         cmp    3,x
  FE12:  270c         beq    LFE20
LFE14:
  FE14:  85           tpa    
  FE15:  2406         bcc    LFE1D
  FE17:  aa04         ora    #$04
  FE19:  a47f         and    #$7F
  FE1B:  2002         bra    LFE1F
LFE1D:
  FE1D:  a47b         and    #$7B
LFE1F:
  FE1F:  84           tap    
LFE20:
  FE20:  86           pula   
  FE21:  81           rts    
;   .... data/gap FE22-FE2A ....

;---------------------------------------------------------------
; sub_FE2A   [0xFE2A]   <- E2B4, E6C7, F5A9, FD36
;---------------------------------------------------------------
  FE2A:  87           psha   
  FE2B:  650100       cphx   #$0100
  FE2E:  240b         bcc    LFE3B
  FE30:  b6ce         lda    g_scratch
  FE32:  52           div    
  FE33:  b7ce         sta    g_scratch
  FE35:  86           pula   
  FE36:  52           div    
  FE37:  8b           pshh   
  FE38:  88           pulx   
  FE39:  8c           clrh   
  FE3A:  81           rts    
LFE3B:
  FE3B:  8b           pshh   
  FE3C:  89           pshx   
  FE3D:  ae08         ldx    #$08
  FE3F:  4f           clra   
  FE40:  89           pshx   
  FE41:  87           psha   
  FE42:  95           tsx    
LFE43:
  FE43:  6804         lsl    4,x
  FE45:  39ce         rol    g_scratch
  FE47:  49           rola   
  FE48:  f7           sta    ,x
  FE49:  e103         cmp    3,x
  FE4B:  2516         bcs    LFE63
  FE4D:  2609         bne    LFE58
  FE4F:  b6ce         lda    g_scratch
  FE51:  e002         sub    2,x
  FE53:  2407         bcc    LFE5C
  FE55:  f6           lda    ,x
  FE56:  200b         bra    LFE63
LFE58:
  FE58:  b6ce         lda    g_scratch
  FE5A:  e002         sub    2,x
LFE5C:
  FE5C:  b7ce         sta    g_scratch
  FE5E:  f6           lda    ,x
  FE5F:  e203         sbc    3,x
  FE61:  6c04         inc    4,x
LFE63:
  FE63:  6b01dd       dbnz   1,x, LFE43
  FE66:  f7           sta    ,x
  FE67:  8a           pulh   
  FE68:  a703         ais    #$03
  FE6A:  bece         ldx    g_scratch
  FE6C:  86           pula   
  FE6D:  3fce         clr    g_scratch
  FE6F:  81           rts    
;   .... data/gap FE70-FE77 ....

;---------------------------------------------------------------
; sub_FE77   [0xFE77]   <- E2C6
;---------------------------------------------------------------
  FE77:  b7cd         sta    $CD
  FE79:  bfcc         stx    $CC
  FE7B:  3fcb         clr    $CB
  FE7D:  3fca         clr    $CA
  FE7F:  81           rts    
