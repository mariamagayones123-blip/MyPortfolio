import { useEffect, useState } from 'react'

/**
 * Manages open/close state for a command palette and binds the
 * conventional Ctrl+K (Windows/Linux) / Cmd+K (macOS) shortcut to
 * toggle it. Use with components/ui/command.tsx's <CommandDialog>.
 *
 * @example
 * const { open, setOpen } = useCommandPalette()
 * <CommandDialog open={open} onOpenChange={setOpen}>...</CommandDialog>
 */
export function useCommandPalette() {
  const [open, setOpen] = useState(false)

  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if (event.key.toLowerCase() === 'k' && (event.metaKey || event.ctrlKey)) {
        event.preventDefault()
        setOpen((previous) => !previous)
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [])

  return { open, setOpen }
}
