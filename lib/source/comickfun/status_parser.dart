String parseStatus(int status) {
  late String statusString;
  if (status == 1) {
    statusString = 'Ongoing';
  } else if (status == 2) {
    statusString = 'Completed';
  } else if (status == 3) {
    statusString = 'Cancelled';
  } else if (status == 4) {
    statusString = 'On Hiatus';
  } else {
    statusString = 'Unknown';
  }
  return statusString;
}
