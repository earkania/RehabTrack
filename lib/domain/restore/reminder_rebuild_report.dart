/// Non-sensitive tally of reminders rebuilt after a restore.
///
/// Contains only counts (how many medication/measurement/doctor-visit
/// reminders were re-scheduled) plus a success flag. It never contains patient,
/// clinical, or personal data.
class ReminderRebuildReport {
  final bool succeeded;
  final int medicationReminders;
  final int measurementReminders;
  final int doctorVisitReminders;

  const ReminderRebuildReport({
    this.succeeded = true,
    this.medicationReminders = 0,
    this.measurementReminders = 0,
    this.doctorVisitReminders = 0,
  });

  const ReminderRebuildReport.failure()
      : succeeded = false,
        medicationReminders = 0,
        measurementReminders = 0,
        doctorVisitReminders = 0;

  int get total =>
      medicationReminders + measurementReminders + doctorVisitReminders;
}