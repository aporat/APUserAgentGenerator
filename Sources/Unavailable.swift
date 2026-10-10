// 1.x names, kept only so the compiler points at the replacement.
// See "Migrating from 1.x" in the README.

@available(*, unavailable, renamed: "BrowserUserAgent", message: "Use try BrowserUserAgent(device:browser:) or BrowserUserAgent.builder().device(_:).browser(_:).build(); read .value for the string.")
public typealias APWebBrowserAgentBuilder = BrowserUserAgent

@available(*, unavailable, renamed: "AppUserAgent", message: "Use try AppUserAgent.builder().appName(_:)…build(); read .value for the string.")
public typealias APAppUserAgentBuilder = AppUserAgent
