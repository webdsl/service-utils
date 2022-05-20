module newsletter

email newsletterEmail(u: User, subject: String, content: WikiText){
	to(u.email)
	from("noreply@groove.app")
	subject(subject)
	
	output(content)

	navigate unsubscribe(u){ "Unsubscribe from newsletter" }
}

function unsubscribeFromNewsletter(u: User): Bool {
	if (u != null && u.newsletter){
		u.newsletter := false;
		u.save();
	}
	return true;
}

page unsubscribe(u: User){
	var t := unsubscribeFromNewsletter(u)
	if (t){}// no warnigns

	<h2>"Newsletter"</h2>
	<p>"You are now unsubscribed."</p>
	navigate root(){"Back"}
}

access control rules
	rule page unsubscribe(u: User){ true }