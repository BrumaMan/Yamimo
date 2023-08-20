import 'package:flutter/material.dart';

IconData parseStatusIcon(String status) {
  late IconData statusIcon;
  if (status == 'Ongoing') {
    statusIcon = Icons.schedule_outlined;
  } else if (status == 'Completed') {
    statusIcon = Icons.done_all;
  } else if (status == 'Cancelled') {
    statusIcon = Icons.close;
  } else if (status == 'On Hiatus') {
    statusIcon = Icons.pause;
  } else {
    statusIcon = Icons.question_mark;
  }
  return statusIcon;
}
