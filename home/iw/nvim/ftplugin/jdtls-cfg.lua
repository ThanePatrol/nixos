local jdtls = require("jdtls")
local defaults = require("lsp-defaults")

-- Assume project root if any of these files are found
local project_root = require("jdtls.setup").find_root({
	"gradlew",
	"mvnw",
	"pom.xml",
	".git",
})

if not project_root then
	print("Is this a Java project? Assuming that project root is current directory.")
	project_root = vim.fn.getcwd()
end

local project_name = vim.fn.fnamemodify(project_root, ":p:t")

-- Set jdtls workspace dir in ~/.local/share/nvim/jdtls-workspaces/<dir_name>
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. project_name

local config = {
	-- Call jdtls script with lombok
	cmd = {
		"jdtls",
		"-data",
		workspace_dir,
		"--jvm-arg=-javaagent:" .. vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/lombok.jar"),
	},
	root_dir = project_root,
	settings = {
		java = {
			configuration = {
				-- Use :JdtSetRuntime or configure Gradle/Maven cfg with one of the below
				runtimes = {
					{
						name = "JavaSE-21",
						path = "/usr/lib/jvm/java-21-openjdk",
						default = true,
					},
					{
						name = "JavaSE-17",
						path = "/usr/lib/jvm/java-17-openjdk",
					},
					{
						name = "JavaSE-11",
						path = "/usr/lib/jvm/java-11-openjdk",
					},
					{
						name = "JavaSE-1.8",
						path = "/usr/lib/jvm/java-8-openjdk",
					},
				},
			},
		},
	},
	on_attach = defaults.on_attach,
	capabilities = defaults.capabilities,
}

jdtls.start_or_attach(config)
