return {
	"Davidyz/VectorCode",
	version = "*", -- optional, depending on whether you're on nightly or release
	build = "python -m pipx upgrade vectorcode", -- optional but recommended. This keeps your CLI up-to-date.
	dependencies = { "nvim-lua/plenary.nvim" },
}
