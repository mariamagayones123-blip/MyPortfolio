import { useState } from 'react'
import { toast } from 'sonner'
import { Button } from '@components/ui/button'
import { Badge } from '@components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@components/ui/card'
import { Input } from '@components/ui/input'
import { Textarea } from '@components/ui/textarea'
import { Label } from '@components/ui/label'
import { Checkbox } from '@components/ui/checkbox'
import { Switch } from '@components/ui/switch'
import { Separator } from '@components/ui/separator'
import { Skeleton } from '@components/ui/skeleton'
import { Spinner } from '@components/ui/spinner'
import { Text } from '@components/ui/text'
import { Icon } from '@components/ui/icon'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@components/ui/select'
import { Tooltip, TooltipContent, TooltipTrigger } from '@components/ui/tooltip'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@components/ui/dialog'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from '@components/ui/sheet'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@components/ui/dropdown-menu'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@components/ui/tabs'
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@components/ui/accordion'
import { Avatar, AvatarFallback } from '@components/ui/avatar'
import { Section } from '@components/layout/section'
import { Stack } from '@components/layout/stack'
import { Grid } from '@components/layout/grid'
import { PageWrapper } from '@components/layout/page-wrapper'
import { zIndex } from '@lib/z-index'
import { Sparkles, Settings, LogOut, User } from 'lucide-react'

/**
 * Internal reference/QA page for the design system built in Phase 2.
 * Not linked from primary navigation and not a portfolio content
 * section — exists purely so every token, component, and layout
 * primitive can be exercised and visually verified in one place.
 */
export function StyleGuidePage() {
  const [switchOn, setSwitchOn] = useState(false)

  return (
    <PageWrapper title="Design System">
      <Section spacing="lg">
        <Stack gap={2}>
          <Badge variant="outline">Internal / QA only</Badge>
          <Text variant="display">Design System</Text>
          <Text variant="body-lg" className="text-muted-foreground">
            Reference page exercising every design token and component built in Phase 2.
          </Text>
        </Stack>
      </Section>

      <Separator />

      <Section spacing="md">
        <Text variant="h2" className="mb-6">
          Typography
        </Text>
        <Stack gap={3}>
          <Text variant="display">Display heading</Text>
          <Text variant="h1">Heading one</Text>
          <Text variant="h2">Heading two</Text>
          <Text variant="h3">Heading three</Text>
          <Text variant="h4">Heading four</Text>
          <Text variant="h5">Heading five</Text>
          <Text variant="h6">Heading six</Text>
          <Text variant="body-lg">Body large — used for intros and lead paragraphs.</Text>
          <Text variant="body">Body — the default paragraph size across the site.</Text>
          <Text variant="body-sm">Body small — secondary or dense copy.</Text>
          <Text variant="caption">Caption — image captions, metadata.</Text>
          <Text variant="label">Label — form labels, eyebrow text</Text>
          <Text variant="code">const greeting = &quot;hello world&quot;</Text>
        </Stack>
      </Section>

      <Separator />

      <Section spacing="md">
        <Text variant="h2" className="mb-6">
          Buttons &amp; badges
        </Text>
        <Stack gap={6}>
          <Stack direction="row" gap={3} wrap>
            <Button>Default</Button>
            <Button variant="secondary">Secondary</Button>
            <Button variant="outline">Outline</Button>
            <Button variant="ghost">Ghost</Button>
            <Button variant="link">Link</Button>
            <Button variant="destructive">Destructive</Button>
            <Button disabled>Disabled</Button>
            <Button size="icon" aria-label="Settings">
              <Icon icon={Settings} size="sm" />
            </Button>
          </Stack>
          <Stack direction="row" gap={2} wrap>
            <Badge>Default</Badge>
            <Badge variant="secondary">Secondary</Badge>
            <Badge variant="brand">Brand</Badge>
            <Badge variant="success">Success</Badge>
            <Badge variant="warning">Warning</Badge>
            <Badge variant="destructive">Destructive</Badge>
            <Badge variant="outline">Outline</Badge>
          </Stack>
        </Stack>
      </Section>

      <Separator />

      <Section spacing="md">
        <Text variant="h2" className="mb-6">
          Form elements
        </Text>
        <Grid cols={2} gap={6}>
          <Stack gap={4}>
            <Stack gap={2}>
              <Label htmlFor="name">Name</Label>
              <Input id="name" placeholder="Ada Lovelace" />
            </Stack>
            <Stack gap={2}>
              <Label htmlFor="message">Message</Label>
              <Textarea id="message" placeholder="Say hello..." />
            </Stack>
            <Stack gap={2}>
              <Label>Framework</Label>
              <Select defaultValue="react">
                <SelectTrigger>
                  <SelectValue placeholder="Select a framework" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="react">React</SelectItem>
                  <SelectItem value="vue">Vue</SelectItem>
                  <SelectItem value="svelte">Svelte</SelectItem>
                </SelectContent>
              </Select>
            </Stack>
          </Stack>
          <Stack gap={4}>
            <Stack direction="row" gap={2} align="center">
              <Checkbox id="terms" />
              <Label htmlFor="terms">I agree to the terms</Label>
            </Stack>
            <Stack direction="row" gap={2} align="center">
              <Switch id="notifications" checked={switchOn} onCheckedChange={setSwitchOn} />
              <Label htmlFor="notifications">Email notifications</Label>
            </Stack>
            <Stack direction="row" gap={3} align="center">
              <Avatar>
                <AvatarFallback>AL</AvatarFallback>
              </Avatar>
              <Spinner />
              <Skeleton className="h-10 w-32" />
            </Stack>
          </Stack>
        </Grid>
      </Section>

      <Separator />

      <Section spacing="md">
        <Text variant="h2" className="mb-6">
          Overlays
        </Text>
        <Stack direction="row" gap={3} wrap>
          <Dialog>
            <DialogTrigger asChild>
              <Button variant="outline">Open dialog</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Confirm action</DialogTitle>
                <DialogDescription>This is a standard modal dialog.</DialogDescription>
              </DialogHeader>
              <DialogFooter>
                <Button variant="outline">Cancel</Button>
                <Button>Confirm</Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>

          <Sheet>
            <SheetTrigger asChild>
              <Button variant="outline">Open sheet</Button>
            </SheetTrigger>
            <SheetContent>
              <SheetHeader>
                <SheetTitle>Side panel</SheetTitle>
                <SheetDescription>Slides in from the edge of the screen.</SheetDescription>
              </SheetHeader>
            </SheetContent>
          </Sheet>

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline">Open menu</Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent>
              <DropdownMenuLabel>My account</DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuItem>
                <User className="mr-2 h-4 w-4" />
                Profile
              </DropdownMenuItem>
              <DropdownMenuItem variant="destructive">
                <LogOut className="mr-2 h-4 w-4" />
                Log out
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>

          <Tooltip>
            <TooltipTrigger asChild>
              <Button variant="outline">
                <Sparkles className="mr-2 h-4 w-4" />
                Hover me
              </Button>
            </TooltipTrigger>
            <TooltipContent>Tooltips use the popover z-layer token.</TooltipContent>
          </Tooltip>

          <Button variant="outline" onClick={() => toast.success('Toast triggered')}>
            Trigger toast
          </Button>
        </Stack>
      </Section>

      <Separator />

      <Section spacing="md">
        <Text variant="h2" className="mb-6">
          Tabs &amp; accordion
        </Text>
        <Grid cols={2} gap={6}>
          <Tabs defaultValue="overview">
            <TabsList>
              <TabsTrigger value="overview">Overview</TabsTrigger>
              <TabsTrigger value="details">Details</TabsTrigger>
            </TabsList>
            <TabsContent value="overview">
              <Text variant="body-sm">Overview panel content.</Text>
            </TabsContent>
            <TabsContent value="details">
              <Text variant="body-sm">Details panel content.</Text>
            </TabsContent>
          </Tabs>

          <Accordion type="single" collapsible>
            <AccordionItem value="item-1">
              <AccordionTrigger>Is this accessible?</AccordionTrigger>
              <AccordionContent>
                Yes — built on Radix Accordion, fully keyboard navigable.
              </AccordionContent>
            </AccordionItem>
            <AccordionItem value="item-2">
              <AccordionTrigger>Does it support dark mode?</AccordionTrigger>
              <AccordionContent>
                Every component reads from the shared color tokens.
              </AccordionContent>
            </AccordionItem>
          </Accordion>
        </Grid>
      </Section>

      <Separator />

      <Section spacing="md">
        <Text variant="h2" className="mb-6">
          Cards &amp; layout
        </Text>
        <Grid cols={3} gap={6}>
          {['Design tokens', 'Reusable components', 'Motion foundation'].map((title) => (
            <Card key={title}>
              <CardHeader>
                <CardTitle>{title}</CardTitle>
                <CardDescription>Built in Phase 2, ready for content phases.</CardDescription>
              </CardHeader>
              <CardContent>
                <Text variant="body-sm" className="text-muted-foreground">
                  Consistent spacing, radius, and shadow tokens throughout.
                </Text>
              </CardContent>
            </Card>
          ))}
        </Grid>
      </Section>

      <Separator />

      <Section spacing="md">
        <Text variant="h2" className="mb-6">
          Z-index layers
        </Text>
        <Text variant="body-sm" className="text-muted-foreground mb-4">
          Semantic stacking order shared by every overlay component above (dropdown, dialog,
          tooltip, toast, ...). Defined once in lib/z-index.ts and styles/globals.css.
        </Text>
        <Grid cols={4} gap={4}>
          {Object.entries(zIndex).map(([layer, value]) => (
            <Card key={layer}>
              <CardContent className="p-4">
                <Text variant="label">{layer}</Text>
                <Text variant="h4">{value}</Text>
              </CardContent>
            </Card>
          ))}
        </Grid>
      </Section>
    </PageWrapper>
  )
}
