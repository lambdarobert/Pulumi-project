document.getElementById('startServerBtn').addEventListener('click', startServer);

// Trigger the getStatus function when the page finishes loading
window.onload = getStatus;

function startServer() {
	// Retrieve the hcaptcha token
	const hcaptchaDiv = document.getElementById('h-captcha')
	const iframe = hcaptchaDiv.querySelector('iframe')
	const hcaptchaToken = iframe.getAttribute('data-hcaptcha-response')

	// Make the POST request to start the server
	fetch('https://api.robert.zip/server/start', {
		method: 'POST',
		body: new URLSearchParams({
			'hcaptcha_token': hcaptchaToken
		})
	})
		.then(handleResponse)
		.then(displayResponse)
		.catch(displayError);
}

function getStatus() {
	// Make the GET request to get the server status
	fetch('https://api.robert.zip/server/status')
		.then(handleResponse)
		.then(displayResponse)
		.catch(displayError);
}

function handleResponse(response) {
	if (!response.ok) {
		throw new Error(`Request failed with status ${response.status}`);
	}
	return response.text();
}

function displayResponse(responseText) {
	document.getElementById('response').textContent = responseText;
}

function displayError(error) {
	document.getElementById('response').textContent = `An error occurred: ${error.message}`;
}

