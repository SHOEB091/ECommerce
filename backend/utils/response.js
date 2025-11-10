function success(res, data, message = 'Success') {
  res.status(200).json({ success: true, message, data });
}

function error(res, message = 'Something went wrong', status = 500) {
  res.status(status).json({ success: false, message });
}

module.exports = { success, error };
