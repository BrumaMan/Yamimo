String parseStatus(String status) {
  late String statusString;
  if (status == 'ongoing') {
    statusString = 'Ongoing';
  } else if (status == 'completed') {
    statusString = 'Completed';
  } else if (status == 'cancelled') {
    statusString = 'Cancelled';
  } else if (status == 'hiatus') {
    statusString = 'On Hiatus';
  } else {
    statusString = 'Unknown';
  }
  return statusString;
}
