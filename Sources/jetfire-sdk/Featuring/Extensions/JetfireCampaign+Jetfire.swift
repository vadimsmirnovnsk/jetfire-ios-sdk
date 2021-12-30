extension JetFireCampaign {

	var canSchedule: Bool {
		let hasSchedule = self.toaster.hasSchedule || self.push.hasSchedule || self.data.hasSchedule || self.stories.reduce(false, { res, st in return res || st.hasSchedule })

		guard hasSchedule else { return true }

		let schedule: JetFireSchedule?
		if self.hasToaster, self.toaster.hasSchedule {
			schedule = self.toaster.schedule
		} else if self.hasPush, self.push.hasSchedule {
			schedule = self.push.schedule
		} else if self.hasData, self.data.hasSchedule {
			schedule = self.data.schedule
		} else if let story = self.stories.first, story.hasSchedule {
			schedule = story.schedule
		} else {
			schedule = nil
		}

		return schedule?.afterInterval != nil
	}
	
}
