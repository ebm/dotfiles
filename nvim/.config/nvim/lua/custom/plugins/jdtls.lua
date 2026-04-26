-- ~/.config/nvim/lua/custom/plugins/jdtls.lua
return {
  'mfussenegger/nvim-jdtls',
  ft = { 'java' },
  config = function()
    local mason_path = vim.fn.stdpath 'data' .. '/mason/packages'

    -- Collect debug bundles
    local bundles = {}
    vim.list_extend(
      bundles,
      vim.split(vim.fn.glob(mason_path .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar'), '\n', { trimempty = true })
    )
    vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. '/java-test/extension/server/*.jar'), '\n', { trimempty = true }))

    local config = {
      cmd = { vim.fn.exepath 'jdtls' },
      root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', 'mvnw', '.git', 'pom.xml' }, { upward = true })[1]),
      init_options = {
        bundles = bundles,
      },
    }

    require('jdtls').start_or_attach(config)
  end,
}
