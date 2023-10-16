local event_handlers = require 'tryptic.event_handlers'

describe('handle_cursor_moved', function()
  it('makes the expected function calls and updates path_to_line_map', function()
    -- spys
    local get_target_under_cursor_spy = {}
    local update_child_window_spy = {}
    local nvim_win_get_cursor_spy = {}

    -- mocks
    local mock_git = { 'mock_git' }
    local mock_diagnostic = { 'mock_diagnostic' }
    local mock_target = { 'mock_target' }
    local mock_state = {
      windows = {
        current = {
          path = 'a/b/c',
        },
      },
      path_to_line_map = {
        ['a/b/c'] = 2,
      },
    }
    _G.tryptic_mock_vim = {
      api = {
        nvim_win_get_cursor = function(winid)
          table.insert(nvim_win_get_cursor_spy, winid)
          return { 13 }
        end,
      },
    }
    _G.tryptic_mock_view = {
      get_target_under_cursor = function(s)
        table.insert(get_target_under_cursor_spy, s)
        return mock_target
      end,
      update_child_window = function(s, t, d, g)
        table.insert(update_child_window_spy, { s, t, d, g })
      end,
    }

    -- test
    event_handlers.handle_cursor_moved(mock_state, mock_diagnostic, mock_git)
    assert.same({ 0 }, nvim_win_get_cursor_spy)
    assert.same({ { mock_state, mock_target, mock_diagnostic, mock_git } }, update_child_window_spy)
    assert.same({ mock_state }, get_target_under_cursor_spy)
    assert.same(13, mock_state.path_to_line_map['a/b/c'])
  end)
end)
