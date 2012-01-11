
#include "WinMyron.h"

namespace Myron
{
	Window* windowForHandle(HWND hWnd)
	{// no ranged for in vs yet
		for (auto i = begin(windowList); i != end(windowList); i++)
		{
			WinWindow *w = *i;

			if (w->handle() == hWnd) return w;
		}
		return nullptr;
	}

    LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
    {
		Window *win = nullptr;
		int cx, cy, cx2, cy2;
        RECT *r;	
	//PAINTSTRUCT ps;
	//HDC hdc;

	switch (message)
	{
		case WM_CLOSE:
			win = windowForHandle(hWnd);
			if (win)
			{
				try {
					win->events.close();
					DestroyWindow(hWnd);
					return TRUE;
				}
				catch (std::bad_function_call)
				{
					std::cout << "No event close" << std::endl;
				}
			}
			return FALSE;
			break;
		case WM_SIZING:
			r = (RECT*)lParam;
			cx2 = cx = r->right - r->left + 1;
			cy2 = cy = r->bottom - r->top + 1;

			win = windowForHandle(hWnd);
			if (win)
			{
				try {
					win->events.resize(cx, cy);
					if (cx != cx2 || cy != cy2)
					{
						r->right =   r->left + cx - 1;
						r->bottom = r->top + cy - 1;
					}
					return TRUE;
				}
				catch (std::bad_function_call)
				{
					std::cout << "No event resize" << std::endl;

				}
			}

			return FALSE;
			break;

	/*case WM_PAINT:
		hdc = BeginPaint(hWnd, &ps);
		// TODO: Add any drawing code here...
		EndPaint(hWnd, &ps);
		break;*/
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	return 0;

    
    }

    WinWindow::WinWindow(int width, int height)
    {
        hInstance = GetModuleHandle(NULL);
        registerClass();
        createWindow(width, height);
		initGL();
        showWindow();
		setRenderRate(30);
    }

    Window &createWindow(int width, int height)
    {
        WinWindow *win = new WinWindow(width, height);

        windowList.push_back(win);
        
        return *windowList.back();
    }

	bool WinWindow::initGL()
	{
		hDC = GetDC(handle());
		if (hDC == 0)
		{
			// kill wnd
			return false;
		}

		PIXELFORMATDESCRIPTOR pfd = {0};

		pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
		pfd.nVersion = 1;
		pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_GENERIC_ACCELERATED;
		pfd.iPixelType = PFD_TYPE_RGBA;
		pfd.cColorBits = 24;
        pfd.cAlphaBits = 8;
		pfd.cDepthBits = 24;
		pfd.iLayerType = PFD_MAIN_PLANE; // apparently ignored?
	
		GLuint pixelFormat = ChoosePixelFormat(hDC, &pfd);
		if (pixelFormat == 0)
		{
			// kill wnd
			return false;
		}

		if (!SetPixelFormat(hDC, pixelFormat, &pfd))
		{
			// kill wnd
			return false;
		}

		wGL = wglCreateContext(hDC);
		if (wGL == 0)
		{
			// kill wnd
			return false;
		}

		if (!wglMakeCurrent(hDC, wGL))
		{
			// kill wnd
			return false;
		}

		/*GLenum err = glewInit();
		if (GLEW_OK != err)
		{
			// kill wnd
			return false;
		}

		int attribs[] = 
		{
			WGL_CONTEXT_MAJOR_VERSION_ARB, 3,
			WGL_CONTEXT_MINOR_VERSION_ARB, 2,
			WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
			0
		};

		HGLRC wGL32;

		if (wglewIsSupported("WGL_ARB_create_context") == 1)
		{
			wGL32 = wglCreateContextAttribsARB(hDC, 0, attribs);
			wglMakeCurrent(NULL, NULL);
			wglDeleteContext(wGL);
			wglMakeCurrent(hDC, wGL32);
		}
		else
		{
			// no 3.2 possible
			return false;
		}

		int glVersion[2];
		glGetIntegerv(GL_MAJOR_VERSION, &glVersion[0]);
		glGetIntegerv(GL_MINOR_VERSION, &glVersion[1]);

		if (!wGL32)
			return false;*/

		return true;
	}

    bool WinWindow::registerClass()
    {
		WNDCLASSEX wcex = {0};

        wcex.cbSize = sizeof(WNDCLASSEX);

        wcex.style            = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
        wcex.lpfnWndProc    = WndProc;
        wcex.hInstance        = hInstance;
        wcex.hCursor        = LoadCursor(NULL, IDC_ARROW);
        wcex.hbrBackground    = (HBRUSH)(COLOR_WINDOW+1);
        wcex.lpszClassName    = className;

        return RegisterClassEx(&wcex)!=0;
    }

    bool WinWindow::createWindow(int width, int height)
    {
        hWnd = CreateWindowEx(
            WS_EX_APPWINDOW | WS_EX_WINDOWEDGE,
            className,
            L"",
            WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN | WS_CLIPSIBLINGS,
            CW_USEDEFAULT, 0, width, height,
            NULL, NULL, hInstance, NULL);
        if (!hWnd) return false;
        return true;
    }

    void WinWindow::showWindow()
    {
        ShowWindow(hWnd, SW_SHOW);
        SetForegroundWindow(hWnd);
        SetFocus(hWnd);
        UpdateWindow(hWnd);
    }

    void Init(std::function<bool()> setup)
    {
		bool done = false;
        MSG msg;
		DWORD lastFrameTime;

		GLenum err = glewInit();

        if (!setup()) return;

		// render initial frame before loop
		lastFrameTime = timeGetTime();
		doRender(0.0f);

		while (!done)
		{
			if (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
			{
				if (msg.message == WM_QUIT)
				{
					done = true;
				}
				else
				{
					TranslateMessage(&msg);
					DispatchMessage(&msg);
				}
			}
			else
			{
				DWORD now = timeGetTime();
				float dt = (now - lastFrameTime) / 1000.0f;
				doRender(dt);
				lastFrameTime = now;
			}
		}
    }

	void doRender(float dt)
	{
		for (auto win = begin(windowList); win != end(windowList); ++win)
		{
			try {
				(*win)->makeContextCurrent();
				(*win)->events.render(dt);
			}
			catch (std::bad_function_call)
			{
				std::cout << "No event render" << std::endl;
			}

			SwapBuffers((*win)->getDC());
		}
	}


	void WinWindow::makeContextCurrent()
	{
		wglMakeCurrent(hDC, wGL);
	}

    int WinWindow::width()
    {
        RECT r;
        GetWindowRect(hWnd, &r);

        return r.right - r.left + 1;
    }

    int WinWindow::height()
    {
        RECT r;
        GetWindowRect(hWnd, &r);

        return r.bottom - r.top + 1;
    }
        
    void WinWindow::setBounds(int x, int y, int cx, int cy)
    {
        SetWindowPos(hWnd, HWND_TOP, x, y, cx, cy, SWP_SHOWWINDOW);
    }

    void WinWindow::setFocus()
    {
        //SetWindowPos(hWnd, HWND_TOP, 0, 0, 0,0, SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
        SetFocus(hWnd);
    }

    void WinWindow::setRenderRate(float rate)
    {
		// TODO: Validate 'rate'
        renderRate = rate;
    }
}