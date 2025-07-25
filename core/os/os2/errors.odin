package os2

import "core:io"
import "base:runtime"

General_Error :: enum u32 {
	None,

	Permission_Denied,
	Exist,
	Not_Exist,
	Closed,

	Timeout,

	Broken_Pipe,

	// Indicates that an attempt to retrieve a file's size was made, but the
	// file doesn't have a size.
	No_Size,

	Invalid_File,
	Invalid_Dir,
	Invalid_Path,
	Invalid_Callback,
	Invalid_Command,

	Pattern_Has_Separator,

	No_HOME_Variable,
	Env_Var_Not_Found,

	Unsupported,
}

Platform_Error :: _Platform_Error

Error :: union #shared_nil {
	General_Error,
	io.Error,
	runtime.Allocator_Error,
	Platform_Error,
}
#assert(size_of(Error) == size_of(u64))

ERROR_NONE :: Error{}


@(require_results)
is_platform_error :: proc(ferr: Error) -> (err: i32, ok: bool) {
	v := ferr.(Platform_Error) or_else {}
	return i32(v), i32(v) != 0
}


@(require_results)
error_string :: proc(ferr: Error) -> string {
	if ferr == nil {
		return ""
	}
	switch e in ferr {
	case General_Error:
		switch e {
		case .None: return ""
		case .Permission_Denied:      return "permission denied"
		case .Exist:                  return "file already exists"
		case .Not_Exist:              return "file does not exist"
		case .Closed:                 return "file already closed"
		case .Timeout:                return "i/o timeout"
		case .Broken_Pipe:            return "Broken pipe"
		case .No_Size:                return "file has no definite size"
		case .Invalid_File:           return "invalid file"
		case .Invalid_Dir:            return "invalid directory"
		case .Invalid_Path:           return "invalid path"
		case .Invalid_Callback:       return "invalid callback"
		case .Invalid_Command:        return "invalid command"
		case .Unsupported:            return "unsupported"
		case .Pattern_Has_Separator:  return "pattern has separator"
		case .No_HOME_Variable:       return "no $HOME variable"
		case .Env_Var_Not_Found:      return "environment variable not found"
		}
	case io.Error:
		switch e {
		case .None: return ""
		case .EOF:               return "eof"
		case .Unexpected_EOF:    return "unexpected eof"
		case .Short_Write:       return "short write"
		case .Invalid_Write:     return "invalid write result"
		case .Short_Buffer:      return "short buffer"
		case .No_Progress:       return "multiple read calls return no data or error"
		case .Invalid_Whence:    return "invalid whence"
		case .Invalid_Offset:    return "invalid offset"
		case .Invalid_Unread:    return "invalid unread"
		case .Negative_Read:     return "negative read"
		case .Negative_Write:    return "negative write"
		case .Negative_Count:    return "negative count"
		case .Buffer_Full:       return "buffer full"
		case .Unknown, .Empty: //
		}
	case runtime.Allocator_Error:
		switch e {
		case .None:                 return ""
		case .Out_Of_Memory:        return "out of memory"
		case .Invalid_Pointer:      return "invalid allocator pointer"
		case .Invalid_Argument:     return "invalid allocator argument"
		case .Mode_Not_Implemented: return "allocator mode not implemented"
		}
	case Platform_Error:
		return _error_string(i32(e))
	}

	return "unknown error"
}

print_error :: proc(f: ^File, ferr: Error, msg: string) {
	temp_allocator := TEMP_ALLOCATOR_GUARD({})
	err_str := error_string(ferr)

	// msg + ": " + err_str + '\n'
	length := len(msg) + 2 + len(err_str) + 1
	buf := make([]u8, length, temp_allocator)

	copy(buf, msg)
	buf[len(msg)] = ':'
	buf[len(msg) + 1] = ' '
	copy(buf[len(msg) + 2:], err_str)
	buf[length - 1] = '\n'
	write(f, buf)
}
