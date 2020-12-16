; Manipuler des lignes horizontales en assembleur sur Atari ST
; Par Vretrocomputing, 2020.

	bsr	savemode	;Sauvegarder le mode vidéo

	clr.w	-(sp)		;Basse résolution
	move.l	#-1,-(sp)	;Ne pas changer l'adresse physique
	move.l	#-1,-(sp)	;Ne pas changer l'adresse logique
	move.w	#5,-(sp)	;Setscreen
	trap	#14		;XBIOS
	add.l	#12,sp

	DC.W	$a00a		;Line A 10 : Cacher la souris

	move.l	#pi1+2,-(sp)	;Nouvelle palette
	move.w	#6,-(sp)	;Setpalette
	trap	#14		;XBIOS
	addq.l	#6,sp

	move.w	#3,-(sp)	;Logbase
	trap	#14		;XBIOS
	addq.l	#2,sp

	move.l	d0,a3		;Adresse de l'écran

; Copier le lecteur de CD tout en haut de l'écran

	move.l	#pi1+34+(160*89),a0	;Source
	move.l	a3,a1		;Destination

	move.w	#(172+1-89)*160/4-1,d0	;Nombre de longs - 1
copie:
	move.l	(a0)+,(a1)+	;Copier un long
	dbf	d0,copie

; Recopier le lecteur de CD en dessous, en mode miroir

	move.l	#pi1+34+(160*172),a0	;Source
	;Destination : a1 pointe déjà au bon endroit
	;lea	160*84(a3),a1		;Destination

	move.w	#(172+1-89)-1,d1	; Compteur de lignes
copie_ligne:
	move.w	#160/4-1,d0	;Nombre de longs - 1
copie2:
	move.l	(a0)+,(a1)+	;Copier un long
	dbf	d0,copie2

	;sub.l	#160*2,a0	;Ligne source précédente
	lea	-160*2(a0),a0	;Ligne source précédente

	dbf	d1,copie_ligne

; Effacer le bas du framebuffer

	moveq	#0,d1		; Données vides
	move.w	#160*(200-84*2)/4-1,d0
copie3:
	move.l	d1,(a1)+
	dbf	d0,copie3

; Attendre l'appui sur une touche

	move.w	#8,-(sp)	;Cnecin
	trap	#1		;GEMDOS
	addq.l	#2,sp

	bsr	restoremode	;Restaurer le mode vidéo

	clr.w	-(sp)		;Pterm0
	trap	#1		;GEMDOS

;--------------------------------------------------------------------------
; Sauvegader le mode vidéo
;--------------------------------------------------------------------------
savemode:
	move.w	#4,-(sp)	;Getrez
	trap	#14		;XBIOS
	addq.l	#2,sp

	move.w	d0,oldrez	;Sauvegarder l'ancienne résolution

	move.l	#oldpal,a3	;Buffer pour ancienne palette
	moveq	#0,d3		;Commencer avec la couleur 0

loopcol:
	move.w	#-1,-(sp)	;Lire la couleur
	move.w	d3,-(sp)	;Numéro de couleur
	move.w	#7,-(sp)	;Setcolor
	trap	#14		;XBIOS
	addq.l	#6,sp

	move.w	d0,(a3)+	;Sauvegarder la couleur

	addq.w	#1,d3		;Couleur suivante

	cmp.w	#16,d3		;A-t-on traité les 16 couleurs ?
	blt	loopcol		;Non

	rts

;--------------------------------------------------------------------------
; Restaurer le mode vidéo
;--------------------------------------------------------------------------
restoremode:
	move.w	oldrez,-(sp)	;Restaurer l'ancienne résolution
	move.l	#-1,-(sp)	;Ne pas changer l'adresse physique
	move.l	#-1,-(sp)	;Ne pas changer l'adresse logique
	move.w	#5,-(sp)	;Setscreen
	trap	#14		;XBIOS
	add.l	#12,sp

	move.l	#oldpal,-(sp)	;Restaurer l'ancienne palette
	move.w	#6,-(sp)	;Setpalette
	trap	#14		;XBIOS
	addq.l	#6,sp

	rts

;--------------------------------------------------------------------------
; Données
;--------------------------------------------------------------------------

pi1:
	INCBIN	lotus.pi1

;--------------------------------------------------------------------------
; Variables
;--------------------------------------------------------------------------

	SECTION	BSS

oldrez:
	DS.W	1	;Ancienne résolution

oldpal:
	DS.W	16	;Ancienne palette
