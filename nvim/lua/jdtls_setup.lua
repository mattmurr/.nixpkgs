local M = {}

M.setup = function()
  local capabilities = require 'jdtls'.extendedClientCapabilities

  local jdtls_cmd = require('lspconfig')['jdtls'].document_config.default_config.cmd
  jdtls_cmd[1] = "jdt-language-server"

  local config = {
    cmd = jdtls_cmd,
    root_dir = vim.fs.dirname(vim.fs.find({ '.gradlew', '.git', 'mvnw' }, { upward = true })[1]),

    settings = {
      java = {
        signatureHelp = { enabled = true };
        configuration = {
          runtimes = {
            {
              name = 'JavaSE-1.8',
              path = '/nix/store/ia3s2z15s27cgf8b9wq55n0vhk6012hm-zulu8.54.0.21-ca-jdk-8.0.292/zulu-8.jdk/Contents/Home',
            }
          }
        }
      },
    },

    init_options = {
      bundles = {}
    },

    capabilities = capabilities,
    on_attach = function(client, bufnr)
      require 'common'.on_attach(client, bufnr)
      require('jdtls.setup').add_commands()
    end
  }

  require('jdtls').start_or_attach(config)
end

return M
