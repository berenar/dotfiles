return {
	"chrisgrieser/nvim-early-retirement",
	config = true,
	event = "VeryLazy",
	opts = {
		retirementAgeMins = 10,
		minimumBufferNum = 3,
		notificationOnAutoClose = false,
	},
}
