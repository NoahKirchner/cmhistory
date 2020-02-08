//Let's get some REAL contraband stuff in here. Because come on, getting brigged for LIPSTICK is no fun.

//Illicit drugs~
/obj/item/storage/pill_bottle/happy
	name = "Happy pills"
	desc = "Highly illegal drug. When you want to see the rainbow."
	skilllock = 0

/obj/item/storage/pill_bottle/happy/New()
	..()
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )

/obj/item/storage/pill_bottle/zoom
	name = "Zoom pills"
	desc = "Highly illegal drug. Trade brain for speed."
	skilllock = 0

/obj/item/storage/pill_bottle/zoom/New()
	..()
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )

/obj/item/cocaine
	name = "\improper cocaine"
	desc = "Cocaine, blow, powder, co-ca-in-a."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "cokepile"
	var/split = 0
	var/obj/item/reagent_container/cocaine/I

/obj/item/cocaine/proc/Split()
	name = "\improper line of cocaine"
	desc = "A nice refreshing line of blow."
	icon_state = "cokeline"
	split = 1

/obj/item/cocaine/proc/Gather()
	name = "\improper cocaine"
	desc = "Cocaine, blow, powder, co-ca-in-a."	
	icon_state = "cokepile"
	split = 0

/obj/item/cocaine/New()
	I = new /obj/item/reagent_container/cocaine(src)

/obj/item/reagent_container/cocaine
	name = "Coke Internal"
	desc = "You shouldn't see this!"
	New()
		..()
		reagents.add_reagent("cocaine", 5)

/obj/item/cocaine/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/weapon/combat_knife/) || istype(W, /obj/item/weapon/throwing_knife/) || istype(W,/obj/item/spacecash/))
		if(split == 0)
			Split()
			user.visible_message("[user] forms the pile into a neat line with the [W]", \
			"You carefully turn the pile into a line with the [W]")			
		else
			Gather()
			user.visible_message("[user] forms the line into a pile with the [W]", \
			"You scoop up the line into a pile with the [W]")		
	else
		user << "<span class = 'warning'>You need to seperate this pile into lines first, use an ID card</span>"

/obj/item/cocaine/attack_hand(mob/user as mob)
	if(split==0)
		..()
		return
	else
		var/turf/T = get_turf(src)
		var/snortloc = T
		if(T.contents)
			for(var/contained in T.contents)
				if(istype(contained, /mob/living/carbon/) || istype(contained, /obj/structure/table/))
					snortloc = contained

		user.visible_message("[user] just railed a line of coke off of [snortloc], holy shit!", \
		"You rail a line of coke off of [snortloc]! Holy shit!")
		playsound(usr.loc, 'sound/effects/sniff1.ogg', 5, 1)
		I.reagents.trans_to(usr, 6)
		I.reagents.reaction(usr, INGEST)
		Dispose()
		I.Dispose()

/obj/item/cocaine/Dispose()
	. = ..()

/obj/item/reagent_container/cocaine/Dispose()
	. = ..()
	


