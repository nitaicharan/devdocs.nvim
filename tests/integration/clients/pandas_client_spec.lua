local assert = require("luassert")
local client = require("devdocs.infrastructure.clients.pandas_client")

describe("pandas_client", function()
  describe("html_to_markdown", function()
    it("converts <h1>", function()
      local result = client.html_to_markdown("<h1>Hello World</h1>")
      assert.same("# Hello World\n", result)
    end)

    it("converts <img>", function()
      local result = client.html_to_markdown("<img alt='alt' src='link'/>")
      assert.same("![alt](link)\n", result)
    end)

    it("converts <ul>", function()
      local input = [[
        <ul>
          <li>Item 1</li>
          <li>Item 2</li>
        </ul>
      ]]
      local result = client.html_to_markdown(input)
      assert.same("- Item 1\n- Item 2\n", result)
    end)

    it("converts <ol>", function()
      local input = [[
        <ol>
          <li>Item 1</li>
          <li>Item 2</li>
        </ol>
      ]]
      local result = client.html_to_markdown(input)
      assert.same("1.  Item 1\n2.  Item 2\n", result)
    end)

    it("converts <pre> to code block", function()
      local input = [[<pre data-language="javascript">console.log("Hello World")</pre>]]
      local result = client.html_to_markdown(input)
      assert.is_truthy(result:match("```"))
      assert.is_truthy(result:match('console%.log'))
    end)

    it("converts <table>", function()
      local input = [[
        <table>
          <tr>
            <th>Header 1</th>
            <th>Header 2</th>
          </tr>
          <tr>
            <td>Cell 1</td>
            <td>Cell 2</td>
          </tr>
        </table>
      ]]
      local result = client.html_to_markdown(input)
      assert.is_truthy(result:match("Header 1"))
      assert.is_truthy(result:match("Cell 1"))
      assert.is_truthy(result:match("|"))
    end)

    it("converts <a> to link", function()
      local result = client.html_to_markdown('<a href="https://example.com">click here</a>')
      assert.same("[click here](https://example.com)\n", result)
    end)

    it("converts <strong> and <em>", function()
      local result = client.html_to_markdown("<strong>bold</strong> and <em>italic</em>")
      assert.same("**bold** and *italic*\n", result)
    end)

    it("asserts on non-string input", function()
      assert.has_error(function()
        client.html_to_markdown(nil)
      end)
    end)
  end)

  describe("html_to_markdown_async", function()
    it("converts HTML to markdown asynchronously", function()
      local result
      local done = false

      client.html_to_markdown_async("<h1>Hello</h1>", function(markdown)
        result = markdown
        done = true
      end)

      -- vim.system is async; in test env we need to wait for completion
      vim.wait(5000, function() return done end)

      assert.is_true(done)
      assert.is_not_nil(result)
      assert.is_not_nil(string.find(result, "Hello"))
    end)

    it("handles empty HTML input", function()
      local result
      local done = false

      client.html_to_markdown_async("", function(markdown)
        result = markdown
        done = true
      end)

      vim.wait(5000, function() return done end)

      assert.is_true(done)
      assert.is_not_nil(result)
    end)

    it("asserts on non-string html", function()
      assert.has_error(function() client.html_to_markdown_async(123, function() end) end)
    end)

    it("asserts on non-function callback", function()
      assert.has_error(function() client.html_to_markdown_async("<h1>X</h1>", "not a fn") end)
    end)
  end)
end)
