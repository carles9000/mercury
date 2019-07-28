	function alertModal(title, body) {
		// Display error message to the user in a modal
		$('#alert-modal-title').html(title);
		$('#alert-modal-body').html(body);
		$('#alert-modal').modal('show');
	}
